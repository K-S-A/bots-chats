defmodule PresenceChatWeb.ChatsLiveView do
  use Phoenix.LiveView
  alias PresenceChatWeb.Presence

  defp topic(chat_id), do: "chat:#{chat_id}"

  def render(%{chats: _} = assigns) do
    PresenceChatWeb.ChatsView.render("index.html", assigns)
  end

  def mount(%{chats: chats, current_user: current_user}, socket) do
    Enum.each(chats, &PresenceChatWeb.Endpoint.subscribe(topic(&1.id)))

    {:ok,
     assign(socket,
       chats: chats,
       current_user: current_user,
       conn: socket,
       recent_messages: Enum.reduce(chats, %{}, &Map.put(&2, &1.id, Enum.at(&1.messages, 0))),
       users: Enum.reduce(chats, %{}, &Map.put(&2, &1.id, Presence.list_presences(topic(&1.id))))
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
    {:noreply, assign(socket, recent_messages: Map.put(recent_messages, chat.id, message))}
  end

  def handle_info(%{payload: payload}, socket) do
    {:noreply, assign(socket, payload)}
  end

  def handle_info(_payload, socket) do
    {:noreply, socket}
  end
end
