defmodule VendingMachineWeb.TransactionJSON do
  def deposit(%{user: user}) do
     data(user, "Deposit successful")
  end

  def reset(%{user: user}) do
    data(user, "Reset successful")
  end

  def buy(%{total_spent: total_spent, purchased_products: purchased_products, change: change}) do
    %{
      data: %{
        total_spent: total_spent,
        purchased_products: purchased_products,
        change: change
      },
      message: "Transaction successfully"
    }
  end

  def error(error) when is_binary(error) do
    %{error: error}
  end

  def error(%{error: error}) do
    %{error: error}
  end

  def error(%{message: message}) do
    %{message: message}
  end

  defp data(data, message) do
    %{
      data: %{
        user_id: data.id,
        deposit_amount: data.deposit_amount,
        deposit_coins: data.deposit_coins
      },
      message: message
    }
  end
end
