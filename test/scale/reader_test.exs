defmodule Scale.ReaderTest do
  alias Scale.Reader
  use ExUnit.Case

  describe "handle_call(:get_weight..." do
    setup do
      {:ok, uart} = Circuits.UART.start_link()

      :ok =
        Circuits.UART.open(uart, "/dev/slave",
          speed: 9600,
          data_bits: 8,
          framing: Circuits.UART.Framing.Line,
          active: false
        )

      {:ok, uart: uart}
    end

    test "Writes \"W\\r\" to the configured port", %{uart: uart} do
      GenServer.call(Reader, :get_weight)
      assert {:ok, "W\r"} = Circuits.UART.read(uart)
    end

    test "parses a response and returns a weight", %{uart: uart} do
      stable_weight_raw = <<32>> <> "042.42LB" <> <<13>> <> "00" <> <<3>>
      expected_weight = %Scale.Weight{stable: true, units: :lbs, weight: Decimal.new("42.42")}
      Circuits.UART.write(uart, stable_weight_raw)
      assert ^expected_weight = GenServer.call(Reader, :get_weight)
    end
  end
end
