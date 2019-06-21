defmodule PresenceChat.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    belongs_to :chat, PresenceChat.Chats.Chat
    belongs_to :author, PresenceChat.Accounts.User, foreign_key: :author_id
    field :body, :string

    timestamps()
  end

  @doc false
  def changeset(message, attrs \\ %{}) do
    message
    |> cast(attrs, [:body])
    |> (&(if attrs[:author], do: put_assoc(&1, :author, attrs[:author]), else: &1)).()
    |> (&(if attrs[:chat], do: put_assoc(&1, :chat, attrs[:chat]), else: &1)).()
    |> validate_required([:body, :author, :chat])
  end
end
