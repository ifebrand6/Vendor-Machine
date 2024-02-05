defmodule VendingMachineWeb.TransactionController do
  use VendingMachineWeb, :controller
  plug VendingMachineWeb.APIEnsureRolePlug, [:buyer]

  alias VendingMachine.Catalogue.Product
  alias VendingMachine.Accounts
  alias VendingMachine.Catalogue

  action_fallback VendingMachineWeb.FallbackController

  def deposit(conn, %{"amount" => amount}) do
    user = VendingMachine.Accounts.get_user!(conn.assigns.current_user.id)

    case deposit_coin(user, amount) do
      {:ok, updated_user} ->
        render(conn, "deposit.json", user: updated_user)

      {:error, error} ->
        conn
        |> put_status(400)
        |> render("error.json", error: error)
    end
  end

  def reset_balance(conn, _) do
    user = VendingMachine.Accounts.get_user!(conn.assigns.current_user.id)

    config = Pow.Plug.fetch_config(conn)
    require IEx
    IEx.pry()

    case VendingMachine.Accounts.reset_user_balance(user) do
      {:ok, updated_user} ->
        render(conn, "reset.json", user: updated_user)

      {:error, error} ->
        conn
        |> put_status(400)
        |> render("error.json", error: error)
    end
  end

  def buy(conn, %{"product_id" => product_id, "amount" => amount}) do
    user = VendingMachine.Accounts.get_user!(conn.assigns.current_user.id)
    amount = Util.convert_to_integer(amount)
    product = Catalogue.get_product(product_id)

    case product do
      %Product{} ->
        {:ok, total_spent, purchased_products, change} =
          buy_products(user, product, amount)

        # TODO handle exceptions for buy_products
        conn
        |> put_status(:ok)
        |> render("buy.json",
          total_spent: total_spent,
          purchased_products: purchased_products,
          change: change
        )

      nil ->
        conn
        |> put_status(:not_found)
        |> render("error.json", message: "Product not found")
    end
  end

  defp buy_products(user, product, amount) do
    total_spent = Decimal.to_integer(product.cost) * amount
    purchased_products = %{product.id => amount, name: product.product_name}

    # Assumed the user has enough balance for the purchase
    change = Util.calculate_change(total_spent, user.deposit_coins)

    # Update user's deposit and coin balance
    _ = Accounts.update_user_balance(user, total_spent, change)

    {:ok, total_spent, purchased_products, change}
  end

  defp deposit_coin(user, amount) do
    case validate_coin_amount(amount) do
      {:ok, parsed_amount} ->
        deposit_coins(parsed_amount, user)

      {:error, msg} ->
        {:error, msg}
    end
  end

  defp validate_coin_amount(amount) do
    allowed_coins = [5, 10, 20, 50, 100]
    parsed_amount = Util.convert_to_integer(amount)

    if Enum.member?(allowed_coins, parsed_amount) do
      {:ok, parsed_amount}
    else
      {:error, "Invalid coin amount. Must be one of: 5,10,20, AND 100"}
    end
  end

  defp deposit_coins(parsed_amount, user) do
    case VendingMachine.Accounts.update_user_balance(user, parsed_amount) do
      {:ok, updated_user} ->
        {:ok, updated_user}

      {:error, changeset} ->
        {:error, "Failed to update user: #{inspect(changeset.errors)}"}
    end
  end
end
