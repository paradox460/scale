defmodule Scale.Reader do
  alias Scale.Weight

  use GenServer

  @serial_device Application.get_env(:scale, :device)

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

    {:ok, %{uart: uart}}
  end

  @impl true
  def handle_call(:get_weight, _from, %{uart: uart} = state) do
    Circuits.UART.write(uart, "W\r")
    # Note that this is a selective recieve, and on systems with large message
    # volume, can be a bottleneck.
    receive do
      {:circuits_uart, @serial_device, msg} when msg not in ["", "?\r"] ->
        {:reply, Weight.parse(msg), state}
    after
      2_000 -> {:reply, {:error, "no weight or scale found"}, state}
    end
  end

  def get_weight do
    GenServer.call(__MODULE__, :get_weight)
  end
end
