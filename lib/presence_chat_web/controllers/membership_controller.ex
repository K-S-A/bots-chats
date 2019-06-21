defmodule PresenceChatWeb.MembershipController do
  use PresenceChatWeb, :controller

  alias PresenceChat.Memberships
  alias PresenceChat.Memberships.Membership

  def index(conn, _params) do
    memberships = Memberships.list_memberships()
    render(conn, "index.html", memberships: memberships)
  end

  def new(conn, _params) do
    changeset = Memberships.change_membership(%Membership{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"membership" => membership_params}) do
    case Memberships.create_membership(membership_params) do
      {:ok, membership} ->
        conn
        |> put_flash(:info, "Membership created successfully.")
        |> redirect(to: Routes.membership_path(conn, :show, membership))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    membership = Memberships.get_membership!(id)
    render(conn, "show.html", membership: membership)
  end

  def edit(conn, %{"id" => id}) do
    membership = Memberships.get_membership!(id)
    changeset = Memberships.change_membership(membership)
    render(conn, "edit.html", membership: membership, changeset: changeset)
  end

  def update(conn, %{"id" => id, "membership" => membership_params}) do
    membership = Memberships.get_membership!(id)

    case Memberships.update_membership(membership, membership_params) do
      {:ok, membership} ->
        conn
        |> put_flash(:info, "Membership updated successfully.")
        |> redirect(to: Routes.membership_path(conn, :show, membership))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", membership: membership, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    membership = Memberships.get_membership!(id)
    {:ok, _membership} = Memberships.delete_membership(membership)

    conn
    |> put_flash(:info, "Membership deleted successfully.")
    |> redirect(to: Routes.membership_path(conn, :index))
  end
end
