defmodule SignalserverWeb.RoomChannel do
  use SignalserverWeb, :channel
  require Logger
  alias Signalserver.Peers

  @impl true
  @doc """
  After joining room,
  - update peers in that room
  - reply with list of existing peers in the room
  """
  def join("room:" <> room_id, %{"uid" => uid}, socket) do
    current_peers =
      case Peers.get(:peer_bucket, "room:#{room_id}") do
        nil -> []
        cp -> cp
      end

    Peers.put(:peer_bucket, "room:#{room_id}", current_peers ++ [uid])
    Process.send(self(), {:return_peers, room_id, uid}, [])
    {:ok, socket |> assign(%{uid: uid, room_id: room_id})}
  end

  @impl true
  def handle_info({:return_peers, room_id, uid}, socket) do
    current_peers = Peers.get(:peer_bucket, "room:#{room_id}") |> Enum.filter(&(&1 != uid))
    broadcast!(socket, "joined-room", %{self: uid, current_peers: current_peers})
    {:noreply, socket}
  end

  @impl true
  def handle_in(event, payload, socket) do
    broadcast!(socket, event, payload)
    {:noreply, socket}
  end

  @impl true
  def terminate(_, socket) do
    Peers.get(:peer_bucket, "room:" <> socket.assigns.room_id)
    |> update_current_peer_list_upon_peer_disconnect(socket)

    broadcast!(socket, "disconnected", %{room_id: socket.assigns.room_id, uid: socket.assigns.uid})

    Logger.info("#{inspect(socket.assigns.uid)} left room:#{inspect(socket.assigns.room_id)}")
  end

  defp update_current_peer_list_upon_peer_disconnect(current_peers, socket) do
    new_current_peers = current_peers |> Enum.filter(&(&1 != socket.assigns.uid))
    Peers.put(:peer_bucket, "room:" <> socket.assigns.room_id, new_current_peers)
  end
end
