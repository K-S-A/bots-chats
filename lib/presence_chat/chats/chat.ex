defmodule PresenceChat.Chats.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "chats" do
    has_many :messages, PresenceChat.Messages.Message
    has_many :memberships, PresenceChat.Memberships.Membership
    has_many :members, through: [:memberships, :user]
    field :name, :string
    field :admin_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(chat, %{admin: admin} = attrs) do
    chat
    |> cast(Map.merge(attrs, %{admin_id: admin.id}), [:name, :admin_id])
    |> validate_required([:name, :admin_id])
    |> put_assoc(:memberships, [%PresenceChat.Memberships.Membership{user_id: admin.id}])
    |> put_assoc(:messages, [%PresenceChat.Messages.Message{author_id: admin.id, body: "Hi everyone! Let's chat!"}])
    |> unique_constraint(:name, name: :chats_name_index)
  end
end
