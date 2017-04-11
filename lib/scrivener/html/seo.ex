defmodule Scrivener.HTML.SEO do
  @moduledoc """
  SEO related functions for pagination. See [https://support.google.com/webmasters/answer/1663744?hl=en](https://support.google.com/webmasters/answer/1663744?hl=en)
  for more information.
  """
  alias Scrivener.Page
  use Phoenix.HTML

  @defaults Keyword.drop(Scrivener.HTML.defaults, [:view_style])

  @doc """
  """
  def rel_link(%Page{page_number: current_page}, page_number) when current_page + 1 == page_number, do: "next"
  def rel_link(%Page{page_number: current_page}, page_number) when current_page - 1 == page_number, do: "prev"
  def rel_link(_paginator, _page_number), do: "canonical"

  @doc """
  """
  def header_links(conn, %Page{page_number: 1} = paginator, args, opts) do
    next_header_link(conn, paginator, args, opts)
  end
  def header_links(conn, %Page{total_pages: page, page_number: page} = paginator, args, opts) do
    prev_header_link(conn, paginator, args, opts)
  end
  def header_links(conn, paginator, args, opts) do
    {:safe, prev} = prev_header_link(conn, paginator, args, opts)
    {:safe, next} = next_header_link(conn, paginator, args, opts)
    {:safe, [prev, next]}
  end
  def header_links(%Scrivener.Page{} = paginator), do: header_links(nil, paginator, [], [])
  def header_links(%Scrivener.Page{} = paginator, opts), do: header_links(nil, paginator, [], opts)
  def header_links(conn, %Scrivener.Page{} = paginator), do: header_links(conn, paginator, [], [])
  def header_links(conn, paginator, [{_, _} | _] = opts), do: header_links(conn, paginator, [], opts)
  def header_links(conn, paginator, [_ | _] = args), do: header_links(conn, paginator, args, [])

  defp href(conn, paginator, args, opts, page_number) do
    merged_opts = Keyword.merge @defaults, opts
    path = opts[:path] || Scrivener.HTML.find_path_fn(conn && paginator.entries, args)
    url_params = Keyword.drop opts, (Keyword.keys(@defaults) ++ [:path])
    page_param = merged_opts[:page_param]
    params_with_page = url_params ++ [{page_param, page_number}]
    args = [conn, merged_opts[:action]] ++ args
    apply(path, args ++ [params_with_page])
  end

  defp prev_header_link(conn, paginator, args, opts) do
    href = href(conn, paginator, args, opts, paginator.page_number - 1)
    content_tag(:link, [], href: href, rel: rel_link(paginator, paginator.page_number - 1))
  end

  defp next_header_link(conn, paginator, args, opts) do
    href = href(conn, paginator, args, opts, paginator.page_number + 1)
    content_tag(:link, [], href: href, rel: rel_link(paginator, paginator.page_number + 1))
  end
end
