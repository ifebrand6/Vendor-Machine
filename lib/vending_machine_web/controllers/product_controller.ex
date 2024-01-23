defmodule VendingMachineWeb.ProductController do
  use VendingMachineWeb, :controller

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
    product = Catalogue.get_product!(id)
    render(conn, :show, product: product)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Catalogue.get_product!(id)

    with {:ok, %Product{} = product} <- Catalogue.update_product(product, product_params) do
      render(conn, :show, product: product)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Catalogue.get_product!(id)

    with {:ok, %Product{}} <- Catalogue.delete_product(product) do
      send_resp(conn, :no_content, "")
    end
  end
end
