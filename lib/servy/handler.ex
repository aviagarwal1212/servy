defmodule Servy.Handler do
  @moduledoc false
  @pages_path Path.expand("pages", File.cwd!())

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.Plugins
  alias Servy.Parser
  alias Servy.VideoCam
  alias Servy.Tracker

  def handle(request) do
    request
    |> Parser.parse()
    |> Plugins.rewrite_path()
    # |> Plugins.log()
    |> route()
    |> Plugins.track()
    |> format_response()
  end

  @doc """
  Routes the request to the appropriate function, and responds with
  an updated Conv struct.
  """
  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    Servy.PledgeController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    Servy.PledgeController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/sensors"} = conv) do
    task = Task.async(fn -> Tracker.get_location("bigfoot") end)

    snapshots =
      ["camera-1", "camera-2", "camera-3"]
      |> Enum.map(&Task.async(fn -> VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    %{conv | status: 200, resp_body: inspect({snapshots, where_is_bigfoot})}
  end

  def route(%Conv{method: "GET", path: "/kaboom"} = _conv) do
    raise "Kaboom!"
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv) do
    time |> String.to_integer() |> :timer.sleep()

    %{conv | resp_body: "Awake!", status: 200}
  end

  def route(conv = %Conv{method: "GET", path: "/wildthings"}) do
    %{conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(conv = %Conv{method: "GET", path: "/api/bears"}) do
    Servy.Api.BearController.index(conv)
  end

  def route(conv = %Conv{method: "GET", path: "/bears"}) do
    BearController.index(conv)
  end

  def route(conv = %Conv{method: "POST", path: "/bears"}) do
    BearController.create(conv)
  end

  def route(conv = %Conv{method: "GET", path: "/about"}) do
    @pages_path
    |> Path.join("about.html")
    |> Plugins.handle_file(conv)
  end

  def route(conv = %Conv{method: "GET", path: "/md/" <> name}) do
    @pages_path
    |> Path.join("#{name}.md")
    |> File.read!()
    |> Plugins.handle_file(conv)
    |> markdown_to_html()
  end

  def route(conv = %Conv{method: "GET", path: "/bears/new"}) do
    @pages_path
    |> Path.join("form.html")
    |> Plugins.handle_file(conv)
  end

  def route(conv = %Conv{method: "GET", path: "/bears/" <> id}) do
    conv
    |> Map.put(:params, Map.put(conv.params, "id", id))
    |> BearController.show()
  end

  def route(conv = %Conv{method: "DELETE", path: "/bears/" <> _id}) do
    BearController.delete(conv)
  end

  def route(conv = %Conv{method: "GET", path: "/pages/" <> file}) do
    @pages_path
    |> Path.join("#{file}.html")
    |> Plugins.handle_file(conv)
  end

  def route(%Conv{} = conv) do
    %{conv | resp_body: "No #{conv.path} here!", status: 404}
  end

  defp markdown_to_html(conv = %Conv{status: 200}) do
    %{conv | resp_body: Earmark.as_html!(conv.resp_body)}
  end

  defp markdown_to_html(conv = %Conv{}) do
    conv
  end

  @doc """
  Formats the response to be sent back to the client
  """
  def format_response(conv = %Conv{}) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: #{conv.resp_content_type}\r
    Content-Length: #{byte_size(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end
end
