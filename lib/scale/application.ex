defmodule Scale.Application do
  use Application

  def start(_type, _args) do
    children = [
      %{
        id: Scale.Reader,
        start: {Scale.Reader, :start_link, [[]]}
      }
    ]

    children =
      if Application.get_env(:scale, :test) do
        [
          %{
            id: Scale.DummyScale,
            start: {Scale.DummyScale, :start_link, [[]]}
          }
          | children
        ]
      else
        children
      end

    Supervisor.start_link(children, strategy: :one_for_one, name: Scale.Supervisor)
  end
end
