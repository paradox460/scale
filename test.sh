socat -d -d pty,raw,echo=1,link=/dev/master pty,raw,echo=0,link=/dev/slave &
mix deps.get
mix test
