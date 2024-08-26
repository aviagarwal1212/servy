defmodule Servy.Handler do
  @pages_path Path.expand("pages", File.cwd!())

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.Plugins
  alias Servy.Parser

  def handle(request) do
    request
    |> Parser.parse()
    |> Plugins.rewrite_path()
    |> Plugins.log()
    |> route()
    |> Plugins.track()
    |> format_response()
  end

  @doc """
  Routes the request to the appropriate function, and responds with
  an updated Conv struct.
  """
  def route(conv = %Conv{method: "GET", path: "/wildthings"}) do
    %{conv | resp_body: "Bears, Lions, Tigers", status: 200}
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

  def route(conv = %Conv{}) do
    %{conv | resp_body: "No #{conv.path} here!", status: 404}
  end

  @doc """
  Formats the response to be sent back to the client
  """
  def format_response(conv = %Conv{}) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: text/html\r
    Content-Length: #{byte_size(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end
end
