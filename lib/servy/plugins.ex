defmodule Servy.Plugins do
  require Logger

  alias Servy.Conv

  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%Conv{path: "/bears?id=" <> id} = conv) do
    %{conv | path: "/bears/" <> id}
  end

  def rewrite_path(%Conv{} = conv) do
    conv
  end

  def log(%Conv{} = conv) do
    if Mix.env() != :test do
      Logger.info(conv)
    end

    conv
  end

  def track(conv = %Conv{status: 404, path: path}) do
    if Mix.env() != :test do
      Logger.warning("Warning: #{path} is on the loose")
    end

    conv
  end

  def track(%Conv{} = conv) do
    conv
  end

  def emojify(%Conv{status: 200, resp_body: body} = conv) do
    %{conv | resp_body: "🎉 " <> body <> " 🎉"}
  end

  def emojify(%Conv{} = conv) do
    conv
  end

  def handle_file(path, %Conv{} = conv) do
    case File.read(path) do
      {:ok, contents} -> %{conv | status: 200, resp_body: contents}
      {:error, :enoent} -> %{conv | status: 404, resp_body: "File not found"}
      {:error, reason} -> %{conv | status: 500, resp_body: "File error: #{reason}"}
    end
  end
end
