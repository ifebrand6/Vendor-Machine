defmodule VendingMachineWeb.TransactionControllerTest do
  use VendingMachineWeb.ConnCase

  import VendingMachine.CatalogueFixtures
  import VendingMachine.AccountsFixtures

  setup %{conn: conn} do
    user = VendingMachine.Repo.insert!(%VendingMachine.Accounts.User{id: 1, email: "test@example.com"})
    conn = Pow.Plug.assign_current_user(conn, user, [])
    {:ok, conn: conn}
  end

  describe "Deposit API" do
    test "allows user to deposit money", %{conn: conn} do
      _user =
        insert_user(%{
          deposit: 0,
          coin_balance: %{"5" => 0, "10" => 0, "20" => 0, "50" => 0, "100" => 0}
        })

      conn = post(conn, ~p"/api/deposit", %{amount: 50})
      response = json_response(conn, 200)
      %{"message" => message} = response

      assert conn.status == 200
      assert message =~ "Deposit successful"
    end

    test "returns an error for non-existent product", %{conn: conn} do
      _user =
        insert_user(%{
          deposit: 0,
          coin_balance: %{"5" => 0, "10" => 0, "20" => 0, "50" => 0, "100" => 0}
        })

      conn = post(conn, ~p"/api/deposit", %{amount: 30})
      response = json_response(conn, 400)
      %{"error" => error} = response

      assert conn.status == 400
      assert error =~ "Invalid coin amount. Must be one of: 5,10,20, AND 100"
    end
  end

  describe "Buy API" do
    test "allows user to buy products", %{conn: conn} do
      _user =
        insert_user(%{
          deposit: 100,
          coin_balance: %{"5" => 0, "10" => 0, "20" => 0, "50" => 0, "100" => 0}
        })

      %{product: product} = insert_product(%{cost: 30, amount_available: 5})

      conn = post(conn, ~p"/api/buy", %{product_id: product.id, amount: 2})
      response = json_response(conn, 200)
      assert conn.status == 200
      %{"message" => message} = response

      assert message == "Transaction successfully"
    end

    test "returns an error for non-existent product", %{conn: conn} do
      _user =
        insert_user(%{
          deposit: 100,
          coin_balance: %{"5" => 0, "10" => 0, "20" => 0, "50" => 0, "100" => 0}
        })

      conn = post(conn, ~p"/api/buy", %{product_id: 999, amount: 2})
      assert conn.status == 404
    end
  end

  describe "Reset" do
    test "resets user's deposit and coin balance", %{conn: conn} do
      _user =
        insert_user(%{
          deposit: 50,
          coin_balance: %{"5" => 2, "10" => 1, "20" => 0, "50" => 3, "100" => 1}
        })

      conn = post(conn, ~p"/api/reset")
      response = json_response(conn, 200)
      %{"message" => message} = response

      assert conn.status == 200
      assert message =~ "Reset successful"
    end
  end

  defp insert_product(attrs) do
    product = product_fixture_(attrs)
    %{product: product}
  end

  defp insert_user(attrs) do
    user_fixture(attrs)
  end
end
