# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

Code.require_file("config/settings.exs")

for {app, settings} <- Erlangelist.Settings.all do
  config(app, settings)
end
