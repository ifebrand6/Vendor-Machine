defmodule VendingMachineWeb.TransactionJSON do

  def deposit(%{user: user}) do
    %{data:
      %{
        user: user.id,
        deposit_amount: user.deposit_amount,
        deposit_coins: user.deposit_coins
      }
    }
  end

  def error(reason) when is_binary(reason) do
    %{error: reason}
  end

  # You can add additional clauses for different argument types if needed
  def error(%{reason: reason}) do
    %{error: reason}
  end
end
