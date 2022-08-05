defmodule Signalserver.Peers do
  use Agent

  @doc """
  Starts a new peer_bucket.
  """
  def start_link(name) do
    Agent.start_link(fn -> %{} end, name: name)
  end

  @doc """
  Gets a value from the `peer_bucket` by `key`.
  """
  def get(peer_bucket, key) do
    Agent.get(peer_bucket, &Map.get(&1, key))
  end

  @doc """
  Puts the `value` for the given `key` in the `peer_bucket`.
  """
  def put(peer_bucket, key, value) do
    Agent.update(peer_bucket, &Map.put(&1, key, value))
  end

  @doc """
  Deletes `key` from `bucket`.

  Returns the current value of `key`, if `key` exists.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end

end
