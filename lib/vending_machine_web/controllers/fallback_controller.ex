defmodule VendingMachineWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use VendingMachineWeb, :controller

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: VendingMachineWeb.ErrorHTML, json: VendingMachineWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, error_changeset}) do
    message = Util.display_changeset_error(error_changeset)
    render_error(conn, :bad_request, message)
  end

  defp render_error(conn, status, message) do
    conn
    |> put_status(status)
    |> put_view(html: VendingMachineWeb.ErrorHTML, json: VendingMachineWeb.ErrorJSON)
    |> render(:"400", %{error: message})
  end
end
