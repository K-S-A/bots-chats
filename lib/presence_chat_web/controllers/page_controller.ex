defmodule PresenceChatWeb.PageController do
  use PresenceChatWeb, :controller

  def index(conn, _params) do
    conn
    |> redirect(to: "/login")
    # render(conn, "index.html")
  end
end
