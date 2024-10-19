defmodule Servy.Conv do
  use TypedStruct
  alias __MODULE__

  typedstruct do
    field :method, String.t(), default: ""
    field :path, String.t(), default: ""
    field :params, %{String.t() => any()}
    field :headers, %{String.t() => any()}
    field :resp_content_type, String.t(), default: "text/html"
    field :resp_body, String.t(), default: ""
    field :status, non_neg_integer() | nil, default: nil
  end

  def full_status(%Conv{} = conv) do
    "#{conv.status} #{status_reason(conv.status)}"
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
end
