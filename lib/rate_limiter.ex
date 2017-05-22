defmodule RateLimiter do
  @moduledoc """
  Simple "Rate limiter" to try out GenServer and ETS
  """

  use GenServer
  require Logger

  # Max of 5 requests per minute
  @max_per_minute 5
  @clear_after :timer.seconds(60)
  @table :rate_limiter_requests

  ### Client

  @doc """
  Start service
  """
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Send request and update counter on ETS table
  ## Examples
    RateLimiter.log("user1")
    RateLimiter.log("user2")
  """
  def log(uid) do
    case :ets.update_counter(@table, uid, {2, 1}, {uid, 0}) do
      count when count > @max_per_minute ->
        {:error, :rate_limited}
      _count ->
        :ok
    end
  end

  ### Server

  def init(_) do
    # Create ETS table when initiating service
    Logger.debug("Creating #{@table} table...")
    :ets.new(@table, [:set, :named_table, :public, read_concurrency: true, write_concurrency: true])
    schedule_clear()
    {:ok, %{}}
  end

  def handle_info(:clear, state) do
    # Clear table
    Logger.debug("Clearing requests from table...")
    :ets.delete_all_objects(@table)
    schedule_clear()
    {:noreply, state}
  end

  # Clear table every 60 secs
  defp schedule_clear do
    Process.send_after(self(), :clear, @clear_after)
  end
end
