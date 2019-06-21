defmodule PresenceChat.Memberships.Membership do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "memberships" do
    belongs_to :chat, PresenceChat.Chats.Chat
    belongs_to :user, PresenceChat.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [])
    |> (&(if attrs[:user], do: put_assoc(&1, :user, attrs[:user]), else: &1)).()
    |> (&(if attrs[:chat], do: put_assoc(&1, :chat, attrs[:chat]), else: &1)).()
    |> validate_required([])
  end
end
