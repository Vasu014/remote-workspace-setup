# ============================================
#  CUSTOMIZE THIS FILE FOR YOUR SETUP
# ============================================
#
#  Edit these values, then:
#    git add -A && git commit -m "my config" && git push
#

{
  # Linux username (lowercase, no spaces)
  username = "dev";

  # Git commit identity
  git = {
    name = "Your Name";
    email = "your.email@example.com";
  };

  # Server timezone
  # Find yours: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
  timezone = "UTC";

  # Machine hostname (shows in prompt and Tailscale)
  hostname = "dev-workspace";
}
