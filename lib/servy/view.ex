defmodule Servy.View do
  alias Servy.Conv

  @templates_path Path.expand("../../templates", __DIR__)

  def render(conv = %Conv{}, template, bindings \\ []) do
    content =
      @templates_path
      |> Path.join(template)
      |> EEx.eval_file(bindings)

    %{conv | status: 200, resp_body: content}
  end
end
