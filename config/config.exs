import Config

config :scale,
  device: "/dev/cu.usbserial"
  # device: "/dev/master",
  # dummy: true,
  # loopback_device: "/dev/slave"

import_config "#{Mix.env()}.exs"
