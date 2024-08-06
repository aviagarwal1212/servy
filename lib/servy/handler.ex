defmodule Servy.Handler do
  require Logger

  @pages_path Path.expand("../../pages", __DIR__)

  def handle(request) do
    request
    |> parse()
    |> rewrite_path()
    |> log()
    |> route()
    |> track()
    # |> emojify()
    |> format_response()
  end

  def parse(request) do
    [method, path, _] = request |> String.split("\n") |> List.first() |> String.split(" ")
    %{method: method, path: path, resp_body: "", status: nil}
  end

  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%{path: "/bears?id=" <> id} = conv) do
    %{conv | path: "/bears/" <> id}
  end

  def rewrite_path(conv) do
    conv
  end

  def log(conv) do
    Logger.info(conv)
    conv
  end

  def route(%{method: "GET", path: "/wildthings"} = conv) do
    %{conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(%{method: "GET", path: "/bears"} = conv) do
    %{conv | resp_body: "Teddy, Smokey, Paddington", status: 200}
  end

  def route(%{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> handle_file(conv)
  end

  def route(%{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> handle_file(conv)
  end

  def route(%{method: "GET", path: "/bears/" <> id} = conv) do
    %{conv | resp_body: "Bear #{id}", status: 200}
  end

  def route(%{method: "DELETE", path: "/bears/" <> _id} = conv) do
    %{conv | resp_body: "Bears must never be deleted!", status: 403}
  end

  def route(%{method: "GET", path: "/pages/" <> file} = conv) do
    @pages_path
    |> Path.join("#{file}.html")
    |> handle_file(conv)
  end

  def route(conv) do
    %{conv | resp_body: "No #{conv.path} here", status: 404}
  end

  def track(%{status: 404, path: path} = conv) do
    Logger.warning("Warning: #{path} is on the loose")
    conv
  end

  def track(conv) do
    conv
  end

  def emojify(%{status: 200, resp_body: body} = conv) do
    %{conv | resp_body: "🎉 " <> body <> " 🎉"}
  end

  def emojify(conv) do
    conv
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end

  defp handle_file(path, conv) do
    case File.read(path) do
      {:ok, contents} -> %{conv | status: 200, resp_body: contents}
      {:error, :enoent} -> %{conv | status: 404, resp_body: "File not found"}
      {:error, reason} -> %{conv | status: 500, resp_body: "File error: #{reason}"}
    end
  end
end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request |> Servy.Handler.handle() |> IO.puts()

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request |> Servy.Handler.handle() |> IO.puts()

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request |> Servy.Handler.handle() |> IO.puts()

request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request |> Servy.Handler.handle() |> IO.puts()

request = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request |> Servy.Handler.handle() |> IO.puts()

request = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request |> Servy.Handler.handle() |> IO.puts()

request = """
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request |> Servy.Handler.handle() |> IO.puts()

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request |> Servy.Handler.handle() |> IO.puts()

request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request |> Servy.Handler.handle() |> IO.puts()

request = """
GET /pages/about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request |> Servy.Handler.handle() |> IO.puts()
