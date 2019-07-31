defmodule Scale.Weight do
  defstruct [:weight, :units, :stable]

  @type t :: %__MODULE__{
          weight: Decimal.t(),
          units: :lbs | :kg,
          stable: boolean()
        }

  @units %{
    "LB" => :lbs,
    "KG" => :kg
  }

  @doc """
  Parses a binary with weight information from a scale and returns a struct or error

  Weight format is approximately as follows
  <<
    <<32>> Space character, indicating start of frame
      6 chars indicating weight in a decimal value, eg 016.23
      2 chars indicating units, eg LB or KG
    <<13>> ASCII control character, indicating field separation
      1 character indicating stability, is 0 or 1
      _::rest Any remaining characters in the binary
  >>
  """
  @spec parse(binary) :: {:ok, t()} | {:error, any()}
  def parse(
        <<32, raw_weight::binary-size(6), raw_units::binary-size(2), 13,
          stable_bit::binary-size(1), _rest::binary>>
      ) do
    with {:decimal_parsing, {:ok, weight}} <- {:decimal_parsing, Decimal.parse(raw_weight)},
         {:unit_parsing, {:ok, units}} <- {:unit_parsing, Map.fetch(@units, raw_units)},
         stable <- stable_bit == "0",
         {:validity, true} <- {:validity, stable && !Decimal.eq?(weight, Decimal.new(0))} do
      {:ok,
       struct!(__MODULE__, %{
         weight: weight,
         units: units,
         stable: stable
       })}
    else
      {:validity, false} ->
        {:error, "Scale reads 0 or unstable weight"}

      e ->
        {:error, e}
    end
  end
end
