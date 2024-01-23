defmodule VendingMachine.Catalogue.Product do
  use Ecto.Schema
  import Ecto.Changeset
  alias VendingMachine.Accounts.User

  schema "products" do
    field :amount_available, :integer
    field :cost, :decimal
    field :product_name, :string
    belongs_to(:seller, User)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:amount_available, :cost, :product_name])
    |> validate_required([:amount_available, :cost, :product_name])
  end
end
