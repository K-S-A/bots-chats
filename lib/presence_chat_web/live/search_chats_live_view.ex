defmodule PresenceChatWeb.SearchChatsLiveView do
  use Phoenix.LiveView
  alias PresenceChat.Chats
  alias PresenceChatWeb.Presence
  alias PresenceChatWeb.Router.Helpers, as: Routes

  defp topic(chat_id), do: "chat:#{chat_id}"

  def render(%{chats: _} = assigns) do
    PresenceChatWeb.SearchChatsView.render("index.html", assigns)
  end

  def mount(%{user_id: user_id}, socket) do
    chats = Chats.list_chats()
    current_user = PresenceChat.Accounts.get_user!(user_id)

    Enum.each(chats, &PresenceChatWeb.Endpoint.subscribe(topic(&1.id)))

    {:ok,
     assign(socket,
       current_user: current_user,
       chats: chats,
       csrf_token: Phoenix.Controller.get_csrf_token(),
       search: %{query: ""},
       recent_messages: Enum.reduce(chats, %{}, &Map.put(&2, &1.id, Enum.at(&1.messages, 0))),
       users: Enum.reduce(chats, %{}, &Map.put(&2, &1.id, Presence.list_presences(topic(&1.id)))),
       new_chat: Chats.change_chat(%Chats.Chat{}, %{admin: current_user}),
       conn: socket
     )}
  end

  def handle_info(%{event: "presence_diff"}, socket = %{assigns: %{chats: chats}}) do
    {:noreply,
     assign(socket,
       users: Enum.reduce(chats, %{}, &Map.put(&2, &1.id, Presence.list_presences(topic(&1.id))))
     )}
  end

  def handle_info(
        %{event: "message", payload: %{chat: chat, message: message}},
        %{assigns: %{recent_messages: recent_messages}} = socket
      ) do
    {:noreply,
     assign(socket,
       recent_messages: Map.put(recent_messages, chat.id, message)
     )}
  end

  def handle_info(
        %{event: "joined", payload: %{chat: chat, user: _}},
        %{assigns: %{chats: chats}} = socket
      ) do
    {:noreply,
     assign(socket,
       chats: Enum.map(chats, fn c -> if c.id == chat.id, do: chat, else: c end)
     )}
  end

  def handle_info(%{payload: payload}, socket) do
    {:noreply, assign(socket, payload)}
  end

  def handle_info(_payload, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "search",
        %{"search" => %{"query" => query}},
        %{assigns: %{chats: chats, current_user: current_user}} = socket
      ) do
    query = String.trim(query || "")

    chats =
      case query do
        "" ->
          Chats.list_chats()

        _ ->
          updated_chats = Chats.search(query)

          updated_chats
          |> Enum.reject(fn chat -> Enum.any?(chats, &(&1.id == chat.id)) end)
          |> Enum.each(&PresenceChatWeb.Endpoint.subscribe(topic(&1.id)))

          chats
          |> Enum.reject(fn chat -> Enum.any?(updated_chats, &(&1.id == chat.id)) end)
          |> Enum.each(&PresenceChatWeb.Endpoint.unsubscribe(topic(&1.id)))

          updated_chats
      end

    {:noreply,
     assign(socket,
       chats: chats,
       search: %{query: query},
       recent_messages: Enum.reduce(chats, %{}, &Map.put(&2, &1.id, Enum.at(&1.messages, 0))),
       users: Enum.reduce(chats, %{}, &Map.put(&2, &1.id, Presence.list_presences(topic(&1.id)))),
       new_chat: Chats.change_chat(%Chats.Chat{}, %{admin: current_user})
     )}
  end

  def handle_event(
        "create_chat",
        %{"chat" => %{"name" => name}},
        %{assigns: %{chats: _, current_user: current_user, conn: conn}} = socket
      ) do
    name = String.trim(name || "")

    case Chats.create_chat(%{name: name, admin: current_user}) do
      {:ok, chat} ->
        {:stop,
         conn
         |> put_flash(:info, "Chat created successfully.")
         |> live_redirect(to: Routes.live_path(socket, PresenceChatWeb.ChatLiveView, chat))}

      {:error, %Ecto.Changeset{} = new_chat} ->
        {:noreply, assign(socket, new_chat: new_chat)}
    end
  end
end
