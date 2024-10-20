defmodule Servy.Api.BearController do
  alias Servy.Conv

  def index(%Conv{} = conv) do
    json =
      Servy.Wildthings.list_bears()
      |> Poison.encode!(strict_keys: true)

    %{conv | status: 200, resp_body: json, resp_content_type: "application/json"}
  end
end
