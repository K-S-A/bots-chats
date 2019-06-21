defmodule PresenceChatWeb.SearchChatController do
  use PresenceChatWeb, :controller

  alias PresenceChat.Chats
  # alias PresenceChat.Chats.Chat
  alias Phoenix.LiveView
  # alias PresenceChatWeb.ChatLiveView
  alias PresenceChatWeb.SearchChatsLiveView
  plug :authenticate_user

  def index(conn, params) do
    query = String.trim(get_in(params, ["search", "query"]) || "")

    LiveView.Controller.live_render(
      conn,
      SearchChatsLiveView,
      session: %{
        chats: Chats.list_chats(),
        current_user: conn.assigns.current_user,
        search: %{query: query},
        csrf_token: Phoenix.Controller.get_csrf_token() # https://github.com/phoenixframework/phoenix_live_view/issues/111
      }
    )
  end

  defp authenticate_user(conn, _) do
    case get_session(conn, :user_id) do
      nil ->
        conn
        |> Phoenix.Controller.put_flash(:error, "Login required")
        |> Phoenix.Controller.redirect(to: "/sessions/new")
        |> halt()

      user_id ->
        assign(conn, :current_user, PresenceChat.Accounts.get_user!(user_id))
    end
  end
end
