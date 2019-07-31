defmodule Scale.WeightTest do
  alias Scale.Weight
  use ExUnit.Case

  describe "parse/1" do
    test "returns a weight struct when scale has stable weight" do
      stable_weight = <<32>> <> "042.42LB" <> <<13>> <> "00" <> <<3>>

      expected =
        {:ok,
         %Weight{
           weight: Decimal.new("42.42"),
           units: :lbs,
           stable: true
         }}

      assert Weight.parse(stable_weight) == expected
    end

    test "returns an error when weight is unstable" do
      unstable_weight = <<32>> <> "042.42LB" <> <<13>> <> "10" <> <<3>>

      assert Weight.parse(unstable_weight) == {:error, "Scale reads 0 or unstable weight"}
    end

    test "returns an error when weight is zero" do
      zero_weight = <<32>> <> "000.00LB" <> <<13>> <> "00" <> <<3>>

      assert Weight.parse(zero_weight) == {:error, "Scale reads 0 or unstable weight"}
    end

    test "returns an error when decimal parsing fails" do
      invalid_weight = <<32>> <> "xxx.eeLB" <> <<13>> <> "00" <> <<3>>
      assert Weight.parse(invalid_weight) == {:error, {:decimal_parsing, :error}}
    end

    test "returns an error when unit parsing fails" do
      invalid_units_weight = <<32>> <> "042.42KN" <> <<13>> <> "00" <> <<3>>
      assert Weight.parse(invalid_units_weight) == {:error, {:unit_parsing, :error}}
    end
  end
end
