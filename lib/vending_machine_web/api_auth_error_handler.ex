defmodule VendingMachineWeb.APIAuthErrorHandler do
  use VendingMachineWeb, :controller

  def call(conn, :not_authenticated) do
    case get_request_format(conn) do
      "html" ->
        conn
        |> put_flash(:error, "Not authenticated")
        |> redirect(to: "/session/new")

      _ ->
        conn
        |> put_status(401)
        |> json(%{error: %{code: 401, message: "Not authenticated"}})
    end
  end

  defp get_request_format(conn),do: conn.private.phoenix_format
end
