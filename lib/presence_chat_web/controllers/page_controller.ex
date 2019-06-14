defmodule PresenceChatWeb.PageController do
  use PresenceChatWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
