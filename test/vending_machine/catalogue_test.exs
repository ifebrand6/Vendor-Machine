defmodule VendingMachine.CatalogueTest do
  use VendingMachine.DataCase

  alias VendingMachine.Catalogue

  describe "products" do
    alias VendingMachine.Catalogue.Product

    import VendingMachine.CatalogueFixtures

    @invalid_attrs %{amount_available: nil, cost: nil, product_name: nil}

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Catalogue.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Catalogue.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{amount_available: 42, cost: "120.5", product_name: "some product_name"}

      assert {:ok, %Product{} = product} = Catalogue.create_product(valid_attrs)
      assert product.amount_available == 42
      assert product.cost == Decimal.new("120.5")
      assert product.product_name == "some product_name"
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalogue.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()

      update_attrs = %{
        amount_available: 43,
        cost: "456.7",
        product_name: "some updated product_name"
      }

      assert {:ok, %Product{} = product} = Catalogue.update_product(product, update_attrs)
      assert product.amount_available == 43
      assert product.cost == Decimal.new("456.7")
      assert product.product_name == "some updated product_name"
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalogue.update_product(product, @invalid_attrs)
      assert product == Catalogue.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Catalogue.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Catalogue.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Catalogue.change_product(product)
    end
  end
end
