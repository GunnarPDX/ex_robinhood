# ExRobinhood

## Login

```elixir
    # Generate a device token, make sure you store this somewhere
    device_token = ExRobinhood.gen_device_token()

    # Enter credentials along with device token
    ExRobinhood.login("example@example.com", "example_password", device_token)
    # ! In the response you should get a challenge_id if using 2FA, make sure that you store this as well
    challenge_id = resp.challenge_id

    # For 2FA:
    # Submit your SMS code (string)
    ExRobinhood.respond_to_challenge(challenge_id, sms_code)
    # resp.status should have "status" => "validated" if successfull

    # Now re-submit your credentials + device token and challenge_id
    ExRobinhood.login_after_challenge("example@example.com", "example_password", device_token, "", challenge_id)
```


### getting device token manually (Not needed normally)

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