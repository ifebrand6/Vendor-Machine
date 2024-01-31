defmodule VendingMachineWeb.ProductController do
  use VendingMachineWeb, :controller
  plug VendingMachineWeb.APIEnsureRolePlug, [:seller] when action in [:create, :update, :delete]

  alias VendingMachine.Catalogue
  alias VendingMachine.Catalogue.Product

  action_fallback VendingMachineWeb.FallbackController

  def index(conn, _params) do
    products = Catalogue.list_products()
    render(conn, :index, products: products)
  end

  def create(conn, %{"product" => product_params}) do
    with {:ok, %Product{} = product} <- Catalogue.create_product(product_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/products/#{product}")
      |> render(:show, product: product)
    end
  end

  def show(conn, %{"id" => id}) do
    product = Catalogue.get_product(id)

    case product do
      %Product{} ->
        render(conn, :show, product: product)

      nil ->
        conn
        |> put_status(500)
        |> json(%{error: %{status: 404, message: "Product not found"}})
    end
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Catalogue.get_product(id)

    with {:ok, %Product{} = product} <- Catalogue.update_product(product, product_params) do
      render(conn, :show, product: product)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Catalogue.get_product!(id)

    with {:ok, %Product{}} <- Catalogue.delete_product(product) do
      send_resp(conn, 200, "Product deleted successful")
    end
  end
end
