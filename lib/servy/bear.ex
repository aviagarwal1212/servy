defmodule Servy.Bear do
  use TypedStruct
  alias __MODULE__

  typedstruct do
    field(:id, non_neg_integer(), default: nil)
    field(:name, String.t(), default: "")
    field(:type, String.t(), default: "")
    field(:hibernating, boolean(), default: false)
  end

  def is_grizzly(bear = %Bear{}), do: bear.type == "Grizzly"
  def order_ascending_by_name(bear1 = %Bear{}, bear2 = %Bear{}), do: bear1.name <= bear2.name
end
