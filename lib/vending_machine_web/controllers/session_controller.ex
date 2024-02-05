defmodule VendingMachineWeb.SessionController do
  use VendingMachineWeb, :controller

  alias VendingMachineWeb.APIAuthPlug
  alias VendingMachine.Accounts.User

  def(create(conn, %{"user" => user_params})) do
    conn
    |> Pow.Plug.authenticate_user(user_params)
    |> case do
      {:ok, conn} ->
        if active_unique_user_session?(conn) do
          handle_authenticated_with_unique_user_presence(conn)
        else
          handle_authenticated(conn)
        end

      {:error, conn} ->
        handle_authentication_error(conn)
    end
  end

  def renew(conn, _params) do
    config = Pow.Plug.fetch_config(conn)

    conn
    |> APIAuthPlug.renew(config)
    |> case do
      {conn, nil} ->
        conn
        |> put_status(401)
        |> json(%{error: %{status: 401, message: "Invalid token"}})

      {conn, _user} ->
        json(conn, %{
          data: %{
            access_token: conn.private.api_access_token,
            renewal_token: conn.private.api_renewal_token,
            expired_at: conn.private.api_access_token_expired_at
          }
        })
    end
  end

  def delete(conn, _params) do
    conn
    |> Pow.Plug.delete()
    |> json(%{data: %{}})
  end

  def delete_all(conn, %{"unique_session_id" => unique_session_id}) do
    _ = reset_session_metadata(conn, unique_session_id)

    conn
    |> Pow.Plug.delete()
    |> json(%{data: %{}})
  end

  defp active_unique_user_session?(conn) do
    !is_nil(conn.assigns.current_user.unique_session_id)
  end

  defp handle_authenticated(conn) do
    conn = append_to_session_metadata(conn)

    json(conn, %{
      data: %{
        access_token: conn.private.api_access_token,
        renewal_token: conn.private.api_renewal_token,
        expired_at: conn.private.api_access_token_expired_at,
        user: %{
          username: conn.private.current_user.username
        }
      }
    })
  end

  @doc "
     Handle Auth ensures, that there is only one session usable per account at once.
    If someone logs in, and some other is logging in with the same credentials,
    the session from the second one is invalidated and cannot be usable.
    The user must call session/delete_all endpoint to delete all active session and log in again.
  "
  defp handle_authenticated_with_unique_user_presence(conn) do
    conn
    |> put_status(401)
    |> json(%{
      error: %{
        status: 401,
        message: "Logout of all sessions required.",
        data: %{unique_session_token: conn.assigns.current_user.unique_session_id}
      }
    })
  end

  defp handle_authentication_error(conn) do
    conn
    |> put_status(401)
    |> json(%{error: %{status: 401, message: "Invalid email or password"}})
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

  def reset_session_metadata(conn, unique_user_session_id) do
    user_with_active_session = get_user_with_active_session(unique_user_session_id)
    _ = VendingMachine.Accounts.update_user_unique_session_id(user_with_active_session, nil)

    conn.private
    |> Map.get(:pow_session_metadata, [])
    |> Keyword.put(:unique_session_id, nil)
  end

  def get_user_with_active_session(session_id),
    do: VendingMachine.Repo.get_by(User, unique_session_id: session_id)
end
