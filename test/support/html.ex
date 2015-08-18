defmodule Scrivener.Support.HTML do
  alias Scrivener.HTML

  def pages(range), do: Enum.to_list(range) |> Enum.map &({&1, &1})
  def pages_with_first(first, range), do: [{first, first}] ++ pages(range)
  def pages_with_last(range, last), do: pages(range) ++ [{last, last}]
  def pages_with_next(range, next), do: pages(range) ++ [{">>", next}]
  def pages_with_previous(previous, range), do: [{"<<", previous}] ++ pages(range)
  def links_with_opts(paginator, opts \\ []), do: HTML.raw_pagination_links(Enum.into(%Scrivener.Page{}, paginator), Dict.merge([next: false, previous: false, first: false, last: false], opts))

end
# Must do this until Scrivener adds @derive Enumerable
defimpl Enumerable, for: Scrivener.Page do
  def reduce(pages, acc, fun), do: Enum.reduce(pages.entries || [], acc, fun)
  def member?(pages, page), do: page in pages.entries
  def count(pages), do: length(pages.entries)
end
defimpl Access, for: Scrivener.Page do
  def get(pages, key), do: Map.get(pages, key)
  def get_and_update(pages, key, fun), do: Map.get_and_update(pages, key, fun)
end
