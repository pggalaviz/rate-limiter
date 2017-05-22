# Rate Limiter

**Simple rate limiter to try GenServer and ETS**

Run `iex -S mix` and then `RateLimiter.start_link()` to initialize GenServer and create the ETS table.

Then run **RateLimiter.log/1** passing a string as ID, example: `RateLimiter.log("user1")`. This will
update the request counter for the specified ID on the ETS table.

After several requests (5 per minute by default) we'll receive `{:error, :rate_limited}` if we keep calling the **log** function.

Every 60 seconds the ETS table will be cleared, allowing another 5 requests.

#### Example

```
iex> RateLimiter.start_link()
{:ok, #PID<0.108.0>}

iex> RateLimiter.log("user1")
:ok
iex> RateLimiter.log("user1")
:ok
iex> RateLimiter.log("user1")
:ok
iex> RateLimiter.log("user1")
:ok
iex> RateLimiter.log("user1")
:ok
iex> RateLimiter.log("user1")
{:error, :rate_limited}
iex> RateLimiter.log("user1")
{:error, :rate_limited}
iex> :ets.tan2list(:rate_limiter_requests)
[{"user1", 7}]
```




