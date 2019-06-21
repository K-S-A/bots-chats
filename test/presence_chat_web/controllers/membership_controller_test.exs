defmodule PresenceChatWeb.MembershipControllerTest do
  use PresenceChatWeb.ConnCase

  alias PresenceChat.Memberships

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:membership) do
    {:ok, membership} = Memberships.create_membership(@create_attrs)
    membership
  end

  describe "index" do
    test "lists all memberships", %{conn: conn} do
      conn = get(conn, Routes.membership_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Memberships"
    end
  end

  describe "new membership" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.membership_path(conn, :new))
      assert html_response(conn, 200) =~ "New Membership"
    end
  end

  describe "create membership" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.membership_path(conn, :create), membership: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.membership_path(conn, :show, id)

      conn = get(conn, Routes.membership_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Membership"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.membership_path(conn, :create), membership: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Membership"
    end
  end

  describe "edit membership" do
    setup [:create_membership]

    test "renders form for editing chosen membership", %{conn: conn, membership: membership} do
      conn = get(conn, Routes.membership_path(conn, :edit, membership))
      assert html_response(conn, 200) =~ "Edit Membership"
    end
  end

  describe "update membership" do
    setup [:create_membership]

    test "redirects when data is valid", %{conn: conn, membership: membership} do
      conn = put(conn, Routes.membership_path(conn, :update, membership), membership: @update_attrs)
      assert redirected_to(conn) == Routes.membership_path(conn, :show, membership)

      conn = get(conn, Routes.membership_path(conn, :show, membership))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, membership: membership} do
      conn = put(conn, Routes.membership_path(conn, :update, membership), membership: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Membership"
    end
  end

  describe "delete membership" do
    setup [:create_membership]

    test "deletes chosen membership", %{conn: conn, membership: membership} do
      conn = delete(conn, Routes.membership_path(conn, :delete, membership))
      assert redirected_to(conn) == Routes.membership_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.membership_path(conn, :show, membership))
      end
    end
  end

  defp create_membership(_) do
    membership = fixture(:membership)
    {:ok, membership: membership}
  end
end
