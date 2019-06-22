defmodule PresenceChatWeb.ChatLiveView do
  use Phoenix.LiveView
  alias PresenceChat.Chats
  alias PresenceChat.Messages
  alias PresenceChat.Memberships
  alias PresenceChatWeb.Presence
  alias PresenceChatWeb.Presence

  @typing_timeout 2000

  defp topic(chat_id), do: "chat:#{chat_id}"

  def render(%{chat: _} = assigns) do
    PresenceChatWeb.ChatView.render("show.html", assigns)
  end

  # def mount(payload, socket) do
  #   IO.inspect({payload, socket})
  # end

  def mount(%{user_id: user_id}, socket) do
    {:ok, assign(socket, :current_user, PresenceChat.Accounts.get_user!(user_id))}
  end

  def mount(%{chat: chat, current_user: current_user}, socket) do
    Presence.track_presence(
      self(),
      topic(chat.id),
      current_user.id,
      default_user_presence_payload(current_user)
    )

    PresenceChatWeb.Endpoint.subscribe(topic(chat.id))

    {:ok,
     assign(socket,
       chat: chat,
       message: Messages.change_message(),
       current_user: current_user,
       users: Presence.list_presences(topic(chat.id))
     )}
  end

  def handle_params(%{"id" => id}, _uri, %{assigns: %{current_user: current_user}} = socket) do
    chat = Chats.get_chat!(id)
    channel_name = topic(chat.id)

    Presence.track_presence(
      self(),
      channel_name,
      current_user.id,
      default_user_presence_payload(current_user)
    )

    PresenceChatWeb.Endpoint.subscribe(channel_name)

    {:noreply,
     assign(socket,
       chat: chat,
       message: Messages.change_message(),
       users: Presence.list_presences(topic(chat.id))
     )}
  end

  @spec handle_info(map, Phoenix.LiveView.Socket.t()) :: {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_info(%{event: "presence_diff"}, socket = %{assigns: %{chat: chat}}) do
    {:noreply,
     assign(socket,
       users: Presence.list_presences(topic(chat.id))
     )}
  end

  def handle_info(
        %{event: "stop_typing"},
        %{assigns: %{chat: chat, current_user: user, message: message} = assigns} = socket
      ) do
    if assigns[:timer_ref] do
      Process.cancel_timer(assigns.timer_ref)
    end

    Presence.update_presence(self(), topic(chat.id), user.id, %{typing: false})
    {:noreply, assign(socket, message: message, timer_ref: nil)}
  end

  def handle_info(%{payload: %{chat: chat}}, socket) do
    {:noreply, assign(socket, chat: chat)}
  end

  def handle_event(
        "page-active",
        _args,
        %{assigns: %{chat: chat, current_user: current_user}} = socket
      ) do
    Presence.update_presence(self(), topic(chat.id), current_user.id, %{away: false})

    # IO.inspect({args, current_user}, label: "page-active")
    {:noreply, socket}
  end

  def handle_event(
        "page-inactive",
        _args,
        %{assigns: %{chat: chat, current_user: current_user}} = socket
      ) do
    # IO.inspect({args, current_user}, label: "page-inactive")

    Presence.update_presence(self(), topic(chat.id), current_user.id, %{away: true})
    {:noreply, socket}
  end

  def handle_event("message", %{"message" => %{"body" => ""}}, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "message",
        %{"message" => %{"body" => body}},
        %{assigns: %{chat: current_chat, current_user: current_user}} = socket
      ) do
    case Messages.create_message(%{body: body, chat: current_chat, author: current_user}) do
      {:ok, message} ->
        chat = Chats.get_chat!(current_chat.id)

        PresenceChatWeb.Endpoint.broadcast_from(self(), topic(current_chat.id), "message", %{
          chat: chat,
          message: message
        })

        {:noreply, assign(socket, chat: chat, message: Messages.change_message())}

      {:error, message} ->
        {:noreply, assign(socket, message: message)}
    end
  end

  def handle_event(
        "typing",
        _value,
        socket = %{assigns: %{chat: chat, current_user: user} = assigns}
      ) do
    if assigns[:timer_ref] do
      Process.cancel_timer(assigns.timer_ref)
    end

    Presence.update_presence(self(), topic(chat.id), user.id, %{typing: true})

    {:noreply,
     assign(socket,
       timer_ref: Process.send_after(self(), %{event: "stop_typing"}, @typing_timeout)
     )}
  end

  def handle_event(
        "stop_typing",
        value,
        %{assigns: %{chat: chat, current_user: user, message: message}} = socket
      ) do
    message =
      Messages.change_message(message, %{body: value, chat_id: chat.id, author_id: user.id})

    Presence.update_presence(self(), topic(chat.id), user.id, %{typing: false})
    {:noreply, assign(socket, message: message, timer_ref: nil)}
  end

  def handle_event("join", _, %{assigns: %{chat: chat, current_user: current_user}} = socket) do
    # Presence.update_presence(self(), topic(chat.id), current_user.id, %{away: false})
    # chat = Chats.join!(chat, current_user)
    Memberships.create_membership(%{chat: chat, user: current_user})
    chat = Chats.get_chat!(chat.id)

    # chat
    # |> Ecto.Changeset.change()
    # |> Ecto.Changeset.put_assoc(:comments, [%Comment{body: "so-so example!"} | post.comments])
    # |> Repo.update!()

    # IO.inspect({args, current_user}, label: "page-active")
    PresenceChatWeb.Endpoint.broadcast_from(self(), topic(chat.id), "joined", %{chat: chat, user: current_user})

    {:noreply, assign(socket, chat: chat)}
  end

  defp default_user_presence_payload(user) do
    %{
      typing: false,
      away: false,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      user_id: user.id
    }
  end
end
