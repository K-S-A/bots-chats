defmodule PresenceChatWeb.SearchChatsLiveView do
  use Phoenix.LiveView
  alias PresenceChat.Chats
  # alias PresenceChat.Messages
  alias PresenceChatWeb.Presence
  alias PresenceChatWeb.Router.Helpers, as: Routes

  defp topic(chat_id), do: "chat:#{chat_id}"

  def render(%{chats: _} = assigns) do
    PresenceChatWeb.SearchChatsView.render("index.html", assigns)
  end

  # def mount(args, socket) do
  #   IO.inspect(Map.keys(args))
  # end

  def mount(%{user_id: user_id}, socket) do
    chats = Chats.list_chats()

    Enum.each(chats, &PresenceChatWeb.Endpoint.subscribe(topic(&1.id)))

    {:ok,
     assign(socket,
       current_user: PresenceChat.Accounts.get_user!(user_id),
       chats: chats,
       csrf_token: Phoenix.Controller.get_csrf_token(),
       search: %{query: ""},
       recent_messages: Enum.reduce(chats, %{}, &Map.put(&2, &1.id, Enum.at(&1.messages, 0))),
       users: Enum.reduce(chats, %{}, &Map.put(&2, &1.id, Presence.list_presences(topic(&1.id)))),
       new_chat: Chats.change_chat(),
       conn: socket
     )}
  end

  # def mount(
  #       %{chats: chats, current_user: current_user, search: search, csrf_token: csrf_token},
  #       socket
  #     ) do
  #   Enum.each(chats, &PresenceChatWeb.Endpoint.subscribe(topic(&1.id)))

  #   {:ok,
  #    assign(socket,
  #      chats: chats,
  #      current_user: current_user,
  #      search: search,
  #      recent_messages: Enum.reduce(chats, %{}, &Map.put(&2, &1.id, Enum.at(&1.messages, 0))),
  #      conn: socket,
  #      users: Enum.reduce(chats, %{}, &Map.put(&2, &1.id, Presence.list_presences(topic(&1.id)))),
  #      new_chat: Chats.change_chat(),
  #      csrf_token: csrf_token
  #    )}
  # end

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
    {:noreply, assign(socket, recent_messages: Map.put(recent_messages, chat.id, message))}
  end

  def handle_info(
        %{event: "joined", payload: %{chat: chat, user: _}},
        %{assigns: %{chats: chats}} = socket
      ) do
    {:noreply, assign(socket, chats: Enum.map(chats, fn c -> if c.id == chat.id, do: chat, else: c end))}
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
        %{assigns: %{chats: chats, current_user: _}} = socket
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

          # {join, leave} = Enum.split_with(updated_chats, fn chat -> Enum.any?(fn c -> c.id == chat.id end) end)

          updated_chats
      end

    {:noreply,
     assign(socket,
       chats: chats,
       search: %{query: query},
       recent_messages: Enum.reduce(chats, %{}, &Map.put(&2, &1.id, Enum.at(&1.messages, 0))),
       users: Enum.reduce(chats, %{}, &Map.put(&2, &1.id, Presence.list_presences(topic(&1.id)))),
       new_chat: Chats.change_chat()
     )}
  end

  def handle_event(
        "create_chat",
        %{"chat" => %{"name" => name}},
        %{assigns: %{chats: _, current_user: current_user, conn: conn} = assigns} = socket
      ) do
    name = String.trim(name || "")

    # IO.inspect(Routes.chat_path(socket, :show, "1cefb35d-13e3-45eb-bc81-b65757b09f59"), label: "redirect")
    # a =
    #   socket
    #   |> put_flash(:info, "Chat created successfully.")
    #   |> redirect(to: Routes.chat_path(socket, :show, "1cefb35d-13e3-45eb-bc81-b65757b09f59"))
    # IO.inspect(a, label: "a")

    # {:stop, a}
    case Chats.create_chat(%{name: name, admin_id: current_user.id}) do
      {:ok, chat} ->
        # IO.inspect(Routes.chat_path(socket, :show, chat), label: "redirect")

        # IO.inspect(Routes.live_path(socket, PresenceChatWeb.ChatLiveView, chat),
        #   label: "live_redirect"
        # )

        {:stop,
         conn
         |> put_flash(:info, "Chat created successfully.")
         |> live_redirect(
           to:
             Routes.live_path(
               socket,
               PresenceChatWeb.ChatLiveView,
               chat
             )
         )}

      #  |> redirect(to: Routes.chat_path(conn, :show, chat))}

      #   # |> redirect(to: Routes.chat_path(socket, :show, chat.id))}
      #   # |> redirect(to: Routes.chat_path(socket, :show, chat))}

      {:error, %Ecto.Changeset{} = new_chat} ->
        IO.inspect(assigns, label: "assigns")
        {:noreply, assign(socket, new_chat: new_chat)}
    end

    # case Chats.create_chat(%{}) do
    #   {:ok, user} ->
    #     {:stop,
    #      socket
    #      |> put_flash(:info, "user created")
    #      |> redirect(to: Routes.user_path(AppWeb.Endpoint, AppWeb.User.ShowView, user))}
    #   {:error, %Ecto.Changeset{} = changeset} ->
    #     {:noreply, assign(socket, changeset: changeset)}
    # end
    # chats =
    #   case query do
    #     "" ->
    #       Chats.list_chats()

    #     _ ->
    #       Chats.search(query)
    #   end

    # {:noreply,
    #   assign(socket,
    #   chats: chats,
    #   search: %{query: query},
    #   recent_messages: Enum.reduce(chats, %{}, &Map.put(&2, &1.id, Enum.at(&1.messages, 0))),
    #   users: Enum.reduce(chats, %{}, &Map.put(&2, &1.id, Presence.list_presences(topic(&1.id))))
    # )}
  end
end
