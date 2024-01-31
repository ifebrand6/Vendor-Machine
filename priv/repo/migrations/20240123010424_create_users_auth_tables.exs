defmodule VendingMachine.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password_hash, :string
      add :username, :string
      add :deposit_amount, :float, default: 0
      # TODO optimized this
      add :deposit_coins, :map, default: %{5 => 0, 10 => 0, 20 => 0, 50 => 0, 100 => 0}
      add :role, :string
      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
