defmodule VendingMachineWeb.RegistrationController do
  use VendingMachineWeb, :controller

  def create(conn, %{"user" => user_params}) do
    conn
    |> Pow.Plug.create_user(user_params)
    |> case do
      {:ok, _user, conn} ->
        conn = append_to_session_metadata(conn)

        json(conn, %{
          data: %{
            access_token: conn.private.api_access_token,
            renewal_token: conn.private.api_renewal_token,
            expired_at: conn.private.api_access_token_expired_at
          }
        })

      {:error, changeset, conn} ->
        errors = Util.display_changeset_error(changeset)

        conn
        |> put_status(500)
        |> json(%{error: %{status: 500, message: errors}})
    end
  end

  def append_to_session_metadata(conn) do
    session_token =
      Phoenix.Token.sign(VendingMachineWeb.Endpoint, "unique-token", conn.assigns.current_user.id)

    _ =
      VendingMachine.Accounts.update_user_unique_session_id(
        conn.assigns.current_user,
        session_token
      )

    metadata =
      conn.private
      |> Map.get(:pow_session_metadata, [])
      |> Keyword.put(:unique_session_id, session_token)

    Plug.Conn.put_private(conn, :pow_session_metadata, metadata)
  end
end
