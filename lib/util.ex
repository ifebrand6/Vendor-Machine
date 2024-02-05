defmodule Util do
  @allowed_denominations [5, 10, 20, 50, 100]
  def convert_to_integer(value) when is_integer(value), do: value

  def convert_to_integer(value) when is_binary(value) do
    {parsed, _} = Integer.parse(value)
    parsed
  end

  def convert_to_integer(value), do: unsupported_type_error(value)

  defp unsupported_type_error(value) do
    raise ArgumentError, message: "Unsupported type: #{inspect(value)}"
  end

  def calculate_change(total_spent, coin_counts) do
    remaining_coins =
      Enum.reduce(
        @allowed_denominations,
        %{5 => 0, 10 => 0, 20 => 0, 50 => 0, 100 => 0},
        fn denomination, acc ->
          count = Map.get(coin_counts, denomination, 0)
          multiples = div(total_spent, denomination)
          used_coins = min(count, multiples)
          remaining_count = if used_coins > 0, do: count - used_coins, else: count
          _total_spent = total_spent - used_coins * denomination

          Map.put(acc, denomination, remaining_count)
        end
      )

    remaining_coins
  end

  def display_changeset_error(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", _to_string(value))
      end)
    end)
    |> Enum.reduce("", fn {k, v}, acc ->
      joined_errors = Enum.join(v, "; ")
      "#{acc} #{k}: #{joined_errors}"
    end)
  end

  def mapper(changeset), do: changeset

  defp _to_string(val) when is_list(val) do
    Enum.join(val, ",")
  end

  defp _to_string(val), do: to_string(val)
end
