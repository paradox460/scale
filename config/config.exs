import Config

config :scale,
  # device: "/dev/cu.usbserial",
  device: "/dev/master",
  dummy: true

import_config "#{Mix.env()}.exs"
