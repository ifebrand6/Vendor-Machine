defmodule ChangeCalculatorTest do
  use ExUnit.Case
  import Util

  describe "calculate_change/2" do
    test "returns correct remaining coins" do
      coin_counts = %{5 => 2, 10 => 1, 20 => 0, 50 => 3, 100 => 1}

      remaining_coins = calculate_change(20, coin_counts)

      expected_result = %{5 => 2, 10 => 1, 20 => 0, 50 => 0, 100 => 1}

      assert expected_result == remaining_coins
    end

    test "handles zero denomination correctly" do
      coin_counts = %{5 => 2, 10 => 1, 20 => 0, 50 => 3, 100 => 1}

      remaining_coins = calculate_change(20, coin_counts)

      expected_result = %{5 => 2, 10 => 1, 20 => 0, 50 => 0, 100 => 1}

      assert expected_result == remaining_coins
    end

    test "handles total_spent greater than available coins" do
      coin_counts = %{5 => 2, 10 => 1, 20 => 0, 50 => 3, 100 => 1}

      remaining_coins = calculate_change(1000, coin_counts)

      expected_result = %{5 => 0, 10 => 0, 20 => 0, 50 => 0, 100 => 1}

      assert expected_result == remaining_coins
    end
  end
end
