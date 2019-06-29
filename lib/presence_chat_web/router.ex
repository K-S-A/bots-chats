defmodule PresenceChatWeb.Router do
  use PresenceChatWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PresenceChatWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/login", SessionController, :new

    resources "/sessions", SessionController,
      only: [:new, :create, :delete],
      singleton: true

    # get "/chats/search", SearchChatController, :index

    live "/chats/search", SearchChatsLiveView, session: [:user_id]
    live "/chats/:id", ChatLiveView, session: [:user_id]
    get "/sign-up", UserController, :new
    # live “/users/new”, UserLive.New
    # resources "/users", UserController
    # resources "/chats", ChatController
    # resources "/messages", MessageController
    # resources "/memberships", MembershipController
  end

  # Other scopes may use custom stacks.
  # scope "/api", PresenceChatWeb do
  #   pipe_through :api
  # end
end
