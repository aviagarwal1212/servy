defmodule Servy.Parser do
  alias Servy.Conv

  def parse(request) do
    [top, body_line] = String.split(request, "\r\n\r\n")
    [req_line | headers] = String.split(top, "\r\n")
    [method, path, _] = req_line |> String.split(" ")

    headers = parse_headers(headers)
    params = parse_params(headers["Content-Type"], body_line)

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  def parse_headers(headers) do
    Enum.reduce(headers, %{}, fn header, acc ->
      [key, value] = String.split(header, ": ")
      Map.put(acc, key, value)
    end)
  end

  @doc """
  Parses the given param string with the form `key1=val1&key2=val2` into a map
  ## Examples
      iex> params_string = "name=Baloo&type=Brown"
      iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
      %{"name" => "Baloo", "type" => "Brown"}
      iex> Servy.Parser.parse_params("multipart/form-data", params_string)
      %{}
  """
  def parse_params(_content_type = "application/x-www-form-urlencoded", body_line) do
    body_line |> String.trim() |> URI.decode_query()
  end

  def parse_params(_content_type, _body_line) do
    %{}
  end
end
