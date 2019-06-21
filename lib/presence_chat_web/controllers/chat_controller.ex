defmodule PresenceChatWeb.ChatController do
  use PresenceChatWeb, :controller

  alias PresenceChat.Chats
  alias PresenceChat.Chats.Chat
  alias Phoenix.LiveView
  alias PresenceChatWeb.ChatLiveView
  alias PresenceChatWeb.ChatsLiveView
  plug :authenticate_user

  def index(conn, _params) do
    chats = Chats.list_chats()
    # render(conn, "index.html", chats: chats)
    LiveView.Controller.live_render(
      conn,
      ChatsLiveView,
      session: %{chats: chats, current_user: conn.assigns.current_user, csrf_token: Phoenix.Controller.get_csrf_token()}
    )
  end

  def new(conn, _params) do
    changeset = Chats.change_chat(%Chat{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"chat" => %{"name" => name}}) do
    IO.inspect(conn)
    case Chats.create_chat(%{name: name, admin_id: conn.assigns.current_user.id}) do
      {:ok, chat} ->
        conn
        |> put_flash(:info, "Chat created successfully.")
        |> redirect(to: Routes.chat_path(conn, :show, chat))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    chat = Chats.get_chat!(id)

    LiveView.Controller.live_render(
      conn,
      ChatLiveView,
      session: %{chat: chat, current_user: conn.assigns.current_user}
    )
  end

  # def edit(conn, %{"id" => id}) do
  #   chat = Chats.get_chat!(id)
  #   changeset = Chats.change_chat(chat)
  #   render(conn, "edit.html", chat: chat, changeset: changeset)
  # end

  # def update(conn, %{"id" => id, "chat" => chat_params}) do
  #   chat = Chats.get_chat!(id)

  #   case Chats.update_chat(chat, chat_params) do
  #     {:ok, chat} ->
  #       conn
  #       |> put_flash(:info, "Chat updated successfully.")
  #       |> redirect(to: Routes.chat_path(conn, :show, chat))

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       render(conn, "edit.html", chat: chat, changeset: changeset)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   chat = Chats.get_chat!(id)
  #   {:ok, _chat} = Chats.delete_chat(chat)

  #   conn
  #   |> put_flash(:info, "Chat deleted successfully.")
  #   |> redirect(to: Routes.chat_path(conn, :index))
  # end

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
