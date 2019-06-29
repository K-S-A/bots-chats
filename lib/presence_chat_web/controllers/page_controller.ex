defmodule PresenceChatWeb.PageController do
  use PresenceChatWeb, :controller

  def index(conn, _params) do
    conn
    |> redirect(to: "/login")
  end
end
