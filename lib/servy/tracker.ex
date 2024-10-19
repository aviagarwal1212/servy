defmodule Servy.Tracker do
  @doc """
  Simulates sending a request to an external API
  to get the GPS coordinates of a wild_thing.
  """
  def get_location(wild_thing) do
    # CODE GOES HERE TO SEND A REQUEST TO THE EXTERNAL API

    # Sleep to simulate the API delay:
    :timer.sleep(500)

    # Example responses returned from the API:
    locations = %{
      "roscoe" => %{latitude: "44.4280 N", longitude: "110.5885 W"},
      "smokey" => %{latitude: "48.7596 N", longitude: "113.7870 W"},
      "brutus" => %{latitude: "43.7904 N", longitude: "110.6818 W"},
      "bigfoot" => %{latitude: "29.0469 N", longitude: "98.8667 W"},
      "haaku" => %{latitude: "45.5110 N", longitude: "115.8712 W"}
    }

    Map.get(locations, wild_thing)
  end
end
