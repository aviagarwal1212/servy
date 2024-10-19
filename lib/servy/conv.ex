defmodule Servy.Conv do
  use TypedStruct
  alias __MODULE__

  @type params :: %{String.t() => any()}
  @type headers :: %{String.t() => any()}

  typedstruct do
    field(:method, String.t(), default: "")
    field(:path, String.t(), default: "")
    field(:params, params(), default: %{})
    field(:headers, headers(), default: %{})
    field(:resp_content_type, String.t(), default: "text/html")
    field(:resp_body, String.t(), default: "")
    field(:status, non_neg_integer(), default: nil)
  end

  @spec full_status(Conv.t()) :: String.t()
  def full_status(conv = %Conv{}) do
    "#{conv.status} #{status_reason(conv.status)}"
  end

  @spec status_reason(integer()) :: String.t()
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
