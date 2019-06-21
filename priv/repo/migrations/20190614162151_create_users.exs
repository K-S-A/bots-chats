defmodule PresenceChat.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true, autogenerate: true
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :nickname, :string, null: false
      add :email, :string, null: false
      add :encrypted_password, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
