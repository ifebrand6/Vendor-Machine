defmodule VendingMachineWeb.TransactionController do
  use VendingMachineWeb, :controller
  alias VendingMachine.Catalogue.Product
  alias VendingMachine.Accounts
  alias VendingMachine.Catalogue

  def deposit(conn, %{"amount" => amount}) do
    user = Accounts.get_temp_user()

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
    user = Accounts.get_temp_user()

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
    user = Accounts.get_temp_user()
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
    # require IEx;IEx.pry
    total_spent = Decimal.to_integer(product.cost) * amount
    purchased_products = %{product.id => amount, name: product.product_name}

    # Assume the user has enough balance for the purchase
    change = calculate_change(user, total_spent)

    # Update user's deposit and coin balance
    _ = Accounts.update_user_balance(user, total_spent, change)

    {:ok, total_spent, purchased_products, change}
  end

  defp calculate_change(_user, _total_spent) do
    # Your logic to calculate change goes here
    # For simplicity, let's assume the user has exact change
    %{5 => 2, 10 => 1, 20 => 0, 50 => 3, 100 => 1}
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
