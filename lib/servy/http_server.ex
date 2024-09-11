defmodule Servy.HttpServer do
  require Logger

  def start(port) when is_integer(port) and port > 1023 do
    {:ok, listen_socket} =
      :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])

    Logger.info("Listening for connection requests on port #{port}...\n")
    accept_loop(listen_socket)
  end

  def accept_loop(listen_socket) do
    Logger.info("Waiting to accept a client connection...\n")

    {:ok, client_socket} = :gen_tcp.accept(listen_socket)
    Logger.info("Connection accepted \n")
    spawn(fn -> serve(client_socket) end)
    accept_loop(listen_socket)
  end

  def serve(client_socket) do
    IO.puts("#{self() |> inspect()}: working on it")

    client_socket
    |> read_request()
    |> Servy.Handler.handle()
    |> write_response(client_socket)
  end

  def read_request(client_socket) do
    {:ok, request} = :gen_tcp.recv(client_socket, 0)
    Logger.info("Received request:\n#{request}\n")
    request
  end

  def generate_response(_request) do
    """
    HTTP/1.1 200 OK\r
    Content-Type: text/plain\r
    Content-Length: 6\r
    \r
    Hello!
    """
  end

  def write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)
    Logger.info("Sending response:\n#{response}\n")
    :gen_tcp.close(client_socket)
  end
end
