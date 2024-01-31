defmodule VendingMachineWeb.ProductControllerTest do
  use VendingMachineWeb.ConnCase

  import VendingMachine.CatalogueFixtures

  alias VendingMachine.Catalogue.Product

  @create_attrs %{
    amount_available: 42,
    cost: "120.5",
    product_name: "some product_name"
  }
  @update_attrs %{
    amount_available: 43,
    cost: "456.7",
    product_name: "some updated product_name"
  }
  @invalid_attrs %{amount_available: nil, cost: nil, product_name: nil}

  setup %{conn: conn} do
    user = VendingMachine.Repo.insert!(%VendingMachine.Accounts.User{id: 1, email: "test@example.com", role: "seller"})
    conn = Pow.Plug.assign_current_user(conn, user, [])
    {:ok, conn: conn}
  end

  describe "index" do
    test "lists all products", %{conn: conn} do
      conn = get(conn, ~p"/api/products")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create product" do
    test "renders product when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/products", product: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/products/#{id}")

      assert %{
               "id" => ^id,
               "amount_available" => 42,
               "cost" => "120.5",
               "product_name" => "some product_name"
             } = json_response(conn, 200)["data"]
    end

    @tag :skip
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/products", product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update product" do
    setup [:create_product]

    test "renders product when data is valid", %{conn: conn, product: %Product{id: id} = product} do
      conn = put(conn, ~p"/api/products/#{product}", product: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/products/#{id}")

      assert %{
               "id" => ^id,
               "amount_available" => 43,
               "cost" => "456.7",
               "product_name" => "some updated product_name"
             } = json_response(conn, 200)["data"]
    end

    @tag :skip
    test "renders errors when data is invalid", %{conn: conn, product: product} do
      conn = put(conn, ~p"/api/products/#{product}", product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete product" do
    setup [:create_product]

    test "deletes chosen product", %{conn: conn, product: product} do
      conn = delete(conn, ~p"/api/products/#{product}")
      assert response(conn, 200)
    end
  end

  defp create_product(_) do
    product = product_fixture()
    %{product: product}
  end
end
