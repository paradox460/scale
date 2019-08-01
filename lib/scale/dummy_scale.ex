defmodule Scale.DummyScale do
  @moduledoc """
  A dummy scale, responding with random weight requests.

  Can be set to return empty values, error values, and such via state changes. See functions for details
  """

  use GenServer

  @serial_device "/dev/master"

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    {:ok, uart} = Circuits.UART.start_link()

    :ok =
      Circuits.UART.open(uart, @serial_device,
        speed: 9600,
        data_bits: 8,
        framing: Circuits.UART.Framing.Line
      )

    {:ok, %{uart: uart, errors: false}}
  end

  @impl true
  def handle_info({:circuits_uart, @serial_device, "W\r"}, %{uart: uart, errors: false} = state) do
    # Generate random weight
    weight =
      with big_weight <- :rand.uniform(100) |> (&:io_lib.format("~3..0B", [&1])).(),
           small_weight <- :rand.uniform(100) |> (&:io_lib.format("~2..0B", [&1])).() do
        "#{big_weight}.#{small_weight}"
      end

    # Generate random unit
    unit = if :rand.uniform() > 0.5, do: "LB", else: "KG"
    Circuits.UART.write(uart, <<32>> <> weight <> unit <> <<13, 48, 48, 3>>)
    {:noreply, state}
  end

  def handle_info({:circuits_uart, @serial_device, "W\r"}, %{uart: uart, errors: true} = state) do
    Circuits.UART.write(uart, <<32, 48, 48, 48, 46, 48, 48, 76, 66, 13, 49, 48, 3>>)
    {:noreply, state}
  end

  @impl true
  def handle_cast(:toggle_error, %{errors: false} = state) do
    state = Map.put(state, :errors, true)
    {:noreply, state}
  end

  @impl true
  def handle_cast(:toggle_error, %{errors: true} = state) do
    state = Map.put(state, :errors, false)
    {:noreply, state}
  end

  def toggle_error do
    GenServer.cast(__MODULE__, :toggle_error)
  end
end
