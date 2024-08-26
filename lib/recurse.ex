defmodule Recurse do
  def my_map([head | tail] = _list, func) do
    [func.(head) | my_map(tail, func)]
  end

  def my_map([] = _list, _func) do
    []
  end
end
