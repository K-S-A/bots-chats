defmodule PresenceChat.Repo.Migrations.CreateMemberships do
  use Ecto.Migration

  def change do
    create table(:memberships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id), null: false
      add :chat_id, references(:chats, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create index(:memberships, [:user_id])
    create index(:memberships, [:chat_id])
    create unique_index(:memberships, [:user_id, :chat_id])
  end
end
