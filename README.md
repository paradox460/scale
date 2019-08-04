# Scale
Service for reading data from FedEx protocol Scales. It has been tested with Mettler Toledo PS scales, but should work for any scale compatible with the FedEx protocol. More protocol support may eventually be added

## Installation
1. Clone the repo
2. `mix deps.get`
3. `iex -S mix`

## Configuration of Scale
Currently Scales need to be configured with the following settings

| Setting         | Value |
|-----------------|-------|
| Baud            | 9600  |
| ASCII data bits | 8     |
| Parity          | None  |
| Stop Bit        | 1     |
| Protocol        | FedEx |


### Checking/Changing Mettler Toledo scale settings
These instructions are for Mettler Toledo PS scales.
1. Press and hold the Units (two circular arrows) symbol for 10 seconds, until the scale displays `SETuP?`
2. Press the Units key until `BAud` is shown on the display
3. Press the Units (two arrows pointing to a `0`) key to view the baud. If it is not at `9600`, press the Zero button until it reads `9600`.
4. Press the Units key to view the ASCII bit setting. If its not at `8`, press the Zero button until it reads `8`.
5. Press the Units key to view the Parity setting. If its not at `None`, press the Zero button until it reads `None`.
6. Press the Units key to view the Stop Bit setting. If its not at `1`, press the Zero button until it reads `1`.
7. Press the Units key to view the Protocol setting. If its not at `Proto1` (FedEx), press the Zero button until it reads `Proto1`.
8. Press the Units key until `END` is displayed. Press the Zero key until `Save` is displayed. Press the Units key to accept the changes and reboot the scale

## Connecting a scale to a computer
Scales can be connected to a computer using either USB or Serial. A Serial to USB converter may be used.

If you use a Serial to USB converter, make sure you have the proper drivers. Prolific (a serial port chipset) based drivers are more prone to issues than FTDI drivers. Mac OS and many other systems come with FTDI drivers built in; Prolific drivers can be installed on MacOS via Homebrew Cask

```sh
brew cask install prolific-pl2303
```

Once this is installed, you need to find the configured serial port for your scale. Odds are that its at `/dev/cu.usbserial`, but it may not be. Look in `ls /dev/` to find it. It will likely mention usb or serial, not just a plain TTY.

Once you have the serial port, edit `config.exs` and you're ready to go.

## Dummy Scale and Testing
A dummy scale is included for your testing convenience. To use it you will need to use a loopback serial port, such as [tty0tty](https://github.com/freemed/tty0tty) (linux), [com0com](https://sourceforge.net/projects/com0com/) (windows), or [socat](http://www.dest-unreach.org/socat/) (macOS)

Setting up a loopback serial interface is not difficult, but Circuits.UART has a [better guide available](https://github.com/elixir-circuits/circuits_uart#building-and-running-the-unit-tests).

Once you have a virtual port running, edit the `config.exs` file. Comment out the "real" serial port, uncomment the `dummy: true` line and lines containing configuration for the loopback serial interface.
