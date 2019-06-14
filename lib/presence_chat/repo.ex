defmodule PresenceChat.Repo do
  use Ecto.Repo,
    otp_app: :presence_chat,
    adapter: Ecto.Adapters.Postgres
end
