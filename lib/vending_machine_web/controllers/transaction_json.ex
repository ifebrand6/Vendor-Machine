defmodule VendingMachineWeb.TransactionJSON do
  def deposit(%{user: user}) do
    %{
      user: user.id,
      deposit_amount: user.deposit_amount,
      deposit_coins: user.deposit_coins,
      message: "Deposit successful"
    }
  end

  def reset(%{user: user}) do
    %{
      user: user.id,
      deposit_amount: user.deposit_amount,
      deposit_coins: user.deposit_coins,
      message: "Reset successful"
    }
  end

  def buy(%{total_spent: total_spent, purchased_products: purchased_products, change: change}) do
    %{
      total_spent: total_spent,
      purchased_products: purchased_products,
      change: change
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
end
