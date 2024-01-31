defmodule MyAppWeb.EnsureRolePlugTest do
  use MyAppWeb.ConnCase

  alias MyAppWeb.EnsureRolePlug

  @opts ~w(seller)a
  @buyer %{id: 1, role: "buyer"}
  @seller %{id: 2, role: "seller"}

  setup do
    conn =
      build_conn()
      |> Plug.Conn.put_private(:plug_session, %{})
      |> Plug.Conn.put_private(:plug_session_fetch, :done)
      |> Pow.Plug.put_config(otp_app: :vending_machine)
      |> fetch_flash()

    {:ok, conn: conn}
  end

  test "call/2 with no user", %{conn: conn} do
    opts = EnsureRolePlug.init(@opts)
    conn = EnsureRolePlug.call(conn, opts)

    assert conn.halted
  end

  test "call/2 with buyer", %{conn: conn} do
    opts = EnsureRolePlug.init(@opts)

    conn =
      conn
      |> Pow.Plug.assign_current_user(@user, otp_app: :vending_machine)
      |> EnsureRolePlug.call(opts)

    assert conn.halted
    assert redirected_to(conn) == ~p"/"
  end

  test "call/2 with seller", %{conn: conn} do
    opts = EnsureRolePlug.init(@opts)

    conn =
      conn
      |> Pow.Plug.assign_current_user(@seller, otp_app: :vending_machine)
      |> EnsureRolePlug.call(opts)

    refute conn.halted
  end
end
