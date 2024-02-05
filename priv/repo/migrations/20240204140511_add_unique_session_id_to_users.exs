defmodule VendingMachine.Repo.Migrations.AddUniqueSessionIdToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :unique_session_id, :string
    end

    create unique_index(:users, [:unique_session_id])
  end
end
