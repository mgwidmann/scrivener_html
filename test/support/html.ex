defmodule Scrivener.Support.HTML do
  alias Scrivener.HTML

  def pages(range), do: Enum.to_list(range) |> Enum.map(&({&1, &1}))
  def pages_with_first({first, num}, range), do: [{first, num}, {:ellipsis, Phoenix.HTML.raw("&hellip;")}] ++ pages(range)
  def pages_with_first(first, range), do: [{first, first}, {:ellipsis, Phoenix.HTML.raw("&hellip;")}] ++ pages(range)
  def pages_with_last({last, num}, range), do: pages(range) ++ [{:ellipsis, Phoenix.HTML.raw("&hellip;")}, {last, num}]
  def pages_with_last(last, range), do: pages(range) ++ [{:ellipsis, Phoenix.HTML.raw("&hellip;")}, {last, last}]
  def pages_with_next(range, next), do: pages(range) ++ [{">>", next}]
  def pages_with_previous(previous, range), do: [{"<<", previous}] ++ pages(range)
  def links_with_opts(paginator, opts \\ []) do
    paginator
    |> Enum.into(%{})
    |> HTML.raw_pagination_links(Keyword.merge([next: false, previous: false, first: false, last: false], opts))
  end

end
