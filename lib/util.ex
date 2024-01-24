defmodule Util do
  @spec convert_to_integer(binary() | integer()) :: integer()
  def convert_to_integer(value) when is_integer(value), do: value

  def convert_to_integer(value) when is_binary(value) do
    {parsed, _} = Integer.parse(value)
    parsed
  end

  def convert_to_integer(value), do: unsupported_type_error(value)

  defp unsupported_type_error(value) do
    raise ArgumentError, message: "Unsupported type: #{inspect(value)}"
  end
end
