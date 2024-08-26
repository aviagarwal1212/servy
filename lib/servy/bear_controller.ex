defmodule Servy.BearController do
  alias Servy.Wildthings
  alias Servy.Bear
  alias Servy.Conv
  alias Servy.View

  def index(conv = %Conv{}) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_ascending_by_name/2)

    View.render(conv, "index.eex", bears: bears)
  end

  def show(conv = %Conv{params: %{"id" => id}}) do
    bear = Wildthings.get_bear(id)

    View.render(conv, "show.eex", bear: bear)
  end

  def create(conv = %Conv{params: %{"type" => type, "name" => name}}) do
    %{conv | resp_body: "Created a #{type} bear named #{name}!", status: 201}
  end

  def delete(conv = %Conv{}) do
    %{conv | resp_body: "Deleting a bear is forbidden!", status: 403}
  end
end
