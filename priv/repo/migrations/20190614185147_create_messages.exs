defmodule PresenceChat.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :body, :text, null: false
      add :author_id, references(:users, on_delete: :nothing, type: :binary_id), null: false
      add :chat_id, references(:chats, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create index(:messages, [:author_id])
    create index(:messages, [:chat_id])
  end
end
