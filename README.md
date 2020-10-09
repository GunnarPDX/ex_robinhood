# ExRobinhood

## Login

```elixir
    ExRobinhood.login("example@example.com", "example_password", "device_token")
```

### getting device token (currently gen_device_token function does not usually work)

- Go to robinhood.com. Log out if you're already logged in
- Right click > Inspect element
- Click on Network tab
- Enter `token` in the input line at the top where it says "Filter"
- With the network monitor-er open, login to Robinhood
- You'll see two new urls pop up that say "api.robinhood.com" and "/oauth2/token"
- Click the one that's not 0 bytes in size
- Click on Headers, then scroll down to the Request Payload section
- Here, you'll see new JSON parameters for your login. What you'll need here is the device token.
- Make sure you keep this saved


