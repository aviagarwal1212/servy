defmodule Servy.Plugins do
  require Logger


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
end
