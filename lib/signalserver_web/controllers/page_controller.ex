defmodule SignalserverWeb.PageController do
  use SignalserverWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
