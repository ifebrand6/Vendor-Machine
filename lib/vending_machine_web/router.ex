defmodule VendingMachineWeb.Router do
  use VendingMachineWeb, :router
  use Pow.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {VendingMachineWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Pow.Plug.Session, otp_app: :vending_machine
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug VendingMachineWeb.APIAuthPlug, otp_app: :vending_machine
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated, error_handler: VendingMachineWeb.APIAuthErrorHandler
  end

  pipeline :redirect_if_user_is_authenticated do
    plug VendingMachineWeb.RedirectAuthenticatedUserPlug
  end

  scope "/" do
    pipe_through :browser
    pow_routes()
  end

  # API
  scope "/api", VendingMachineWeb do
    pipe_through [:api, :protected]
    resources "/products", ProductController, only: [:create, :update, :delete]

    post "/deposit", TransactionController, :deposit
    post "/reset", TransactionController, :reset_balance
    post "/buy", TransactionController, :buy
  end

  scope "/api", VendingMachineWeb do
    pipe_through [:api]
    resources "/registration", RegistrationController, singleton: true, only: [:create]
    resources "/session", SessionController, singleton: true, only: [:create, :delete]
    post "/session/renew", SessionController, :renew
    delete "/session/delete_all", SessionController, :delete_all

    resources "/products", ProductController, only: [:index, :show]
  end

  # LiveView CLIENT
  scope "/", VendingMachineWeb do
    pipe_through [:browser, :protected]

    live_session :default, session: {__MODULE__, :with_session, []} do
      live "/", StoreLive.Index, :index

      live "/products", ProductLive.Index, :index
      live "/products/new", ProductLive.Index, :new
      live "/products/:id/edit", ProductLive.Index, :edit

      live "/products/:id", ProductLive.Show, :show
      live "/products/:id/show/edit", ProductLive.Show, :edit
    end
  end

  scope "/" do
    pipe_through :browser
       resources "/registration", RegistrationController, singleton: true, only: [:create]
  end

  def with_session(conn) do
      %{
        "path" => "/" <> Enum.join(conn.path_info, "/"),
        "current_user" => conn.assigns.current_user
      }
    end

end
