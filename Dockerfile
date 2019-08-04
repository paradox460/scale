FROM elixir:1.9.1
MAINTAINER Jeff Sandberg <jeff@pdx.su>
VOLUME /app
WORKDIR /app
ENV MIX_ENV=test
RUN apt-get update && apt-get install -y socat && mix local.hex --force && mix deps.get
CMD /bin/bash test.sh
