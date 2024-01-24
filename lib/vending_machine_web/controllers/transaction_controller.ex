defmodule VendingMachineWeb.TransactionController do
  use VendingMachineWeb, :controller

  alias VendingMachine.Accounts

  def deposit(conn, %{"amount" => amount}) do
    user = Accounts.get_user!(1)

    case deposit_coin(user, amount) do
      {:ok, updated_user} ->
        render(conn, "deposit.json", user: updated_user)

      {:error, reason} ->
        render(conn, "error.json", reason: reason)
    end
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
    parsed_amount = String.to_integer(amount)
    if Enum.member?(allowed_coins, parsed_amount) do
      {:ok, parsed_amount}
    else
      {:error, "Invalid coin amount. Must be one of: 5,10,20, AND 100}"}
    end
  end




  defp deposit_coins(parsed_amount, user) do
    case VendingMachine.Accounts.update_user_balance(user, parsed_amount) do
      {:ok, updated_user} ->
          {:ok, updated_user}
      {:error, changeset} -> {:error, "Failed to update user: #{inspect(changeset.errors)}"}
    end
  end
end
