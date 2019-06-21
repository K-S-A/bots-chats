defmodule PresenceChat.MembershipsTest do
  use PresenceChat.DataCase

  alias PresenceChat.Memberships

  describe "memberships" do
    alias PresenceChat.Memberships.Membership

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def membership_fixture(attrs \\ %{}) do
      {:ok, membership} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Memberships.create_membership()

      membership
    end

    test "list_memberships/0 returns all memberships" do
      membership = membership_fixture()
      assert Memberships.list_memberships() == [membership]
    end

    test "get_membership!/1 returns the membership with given id" do
      membership = membership_fixture()
      assert Memberships.get_membership!(membership.id) == membership
    end

    test "create_membership/1 with valid data creates a membership" do
      assert {:ok, %Membership{} = membership} = Memberships.create_membership(@valid_attrs)
    end

    test "create_membership/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Memberships.create_membership(@invalid_attrs)
    end

    test "update_membership/2 with valid data updates the membership" do
      membership = membership_fixture()
      assert {:ok, %Membership{} = membership} = Memberships.update_membership(membership, @update_attrs)
    end

    test "update_membership/2 with invalid data returns error changeset" do
      membership = membership_fixture()
      assert {:error, %Ecto.Changeset{}} = Memberships.update_membership(membership, @invalid_attrs)
      assert membership == Memberships.get_membership!(membership.id)
    end

    test "delete_membership/1 deletes the membership" do
      membership = membership_fixture()
      assert {:ok, %Membership{}} = Memberships.delete_membership(membership)
      assert_raise Ecto.NoResultsError, fn -> Memberships.get_membership!(membership.id) end
    end

    test "change_membership/1 returns a membership changeset" do
      membership = membership_fixture()
      assert %Ecto.Changeset{} = Memberships.change_membership(membership)
    end
  end
end
