defmodule VendingMachine.CatalogueFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VendingMachine.Catalogue` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        amount_available: 42,
        cost: "120.5",
        product_name: "some product_name"
      })
      |> VendingMachine.Catalogue.create_product()

    product
  end

  def product_fixture_(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        product_name: "some product_name-#{System.unique_integer()}"
      })
      |> VendingMachine.Catalogue.create_product()

    product
  end
end
