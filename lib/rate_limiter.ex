defmodule RateLimiter do
  @moduledoc """
  Simple "Rate limiter" to try out GenServer and ETS
  """

  use GenServer
  require Logger
  
  # Max of 5 requests per minute
  @max_per_minute 5
  @clear_after :timer.seconds(60)

  ### Client
  @doc """
  Start service
  """
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Send request and add it to state
  ## Examples
    RateLimiter.log("user1")
    RateLimiter.log("user2")
  """
  def log(uid) do
    GenServer.call(__MODULE__, {:log, uid})
  end

  ### Server

  def init(_) do
    schedule_clear()
    {:ok, %{requests: %{}}}
  end

  def handle_info(:clear, state) do
    Logger.debug("Clearing requests...")
    schedule_clear()
    {:noreply, %{state | requests: %{}}}
  end

  def handle_call({:log, uid}, _from, state) do
    # If user exists on current state
    case state.requests[uid] do
      # If no previous count or count is less than limit.
      count when is_nil(count) or count < @max_per_minute ->
        {:reply, :ok, put_in(state, [:requests, uid], (count || 0) + 1)}
      # If limit is reached.
      count when count >= @max_per_minute ->
        {:reply, {:error, :rate_limited}, state}
    end
  end

  # Private

  defp schedule_clear do
    Process.send(self(), :clear, @clear_after)
  end
end
