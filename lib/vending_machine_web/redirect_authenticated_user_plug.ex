defmodule VendingMachineWeb.RedirectAuthenticatedUserPlug do
  @moduledoc false

  import Plug.Conn

  import Phoenix.Controller, only: [redirect: 2]

  @spec init(any()) :: any()
  def init(opts), do: opts

  @doc false

  def call(%Plug.Conn{assigns: %{current_user: nil}, request_path: "/"} = conn, _opts), do: conn

  def call(%Plug.Conn{assigns: %{current_user: _user}, request_path: "/"} = conn, _opts) do
    conn
    |> redirect(to: "/products")
    |> halt()
  end

  def call(conn, _opts), do: conn
end
