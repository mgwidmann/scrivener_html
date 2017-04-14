defmodule Scrivener.HTML.SEO do
  @moduledoc """
  SEO related functions for pagination. See [https://support.google.com/webmasters/answer/1663744?hl=en](https://support.google.com/webmasters/answer/1663744?hl=en)
  for more information.

  `Scrivener.HTML.pagination_links/4` will use this module to add `rel` to each link produced to indicate to search engines which
  link is the `next` or `prev`ious link in the chain of links. The default is `rel` value is `canonical` otherwise.

  Additionally, it helps Google and other search engines to put `<link/>` tags in the `<head>`. The `Scrivener.HTML.SEO.header_links/4`
  function requires the same arguments you passed into your `Scrivener.HTML.pagination_links/4` call in the view. However, `header_links` needs
  to go into the `<head>` section of your page. See [SEO Tags in Phoenix](http://blog.danielberkompas.com/2016/01/28/seo-tags-in-phoenix.html)
  for help with how to do that. The recommended option is to use `render_existing/2` in your layout file and add a separate view to render that.
  """
  alias Scrivener.Page
  use Phoenix.HTML

  @defaults Keyword.drop(Scrivener.HTML.defaults, [:view_style])

  @doc ~S"""
  Produces the value for a `rel` attribute in an `<a>` tag. Returns either `"next"`, `"prev"` or `"canonical"`.

      iex> Scrivener.HTML.SEO.rel(%Scrivener.Page{page_number: 5}, 4)
      "prev"
      iex> Scrivener.HTML.SEO.rel(%Scrivener.Page{page_number: 5}, 6)
      "next"
      iex> Scrivener.HTML.SEO.rel(%Scrivener.Page{page_number: 5}, 8)
      "canonical"
  """
  def rel(%Page{page_number: current_page}, page_number) when current_page + 1 == page_number, do: "next"
  def rel(%Page{page_number: current_page}, page_number) when current_page - 1 == page_number, do: "prev"
  def rel(_paginator, _page_number), do: "canonical"

  @doc ~S"""
  Produces `<link/>` tags for putting in the `<head>` to help SEO as recommended by Google webmasters.

  Arguments are the same as `Scrivener.HTML.pagination_links/4`. Consider using one of the following techniques to
  call this function: [http://blog.danielberkompas.com/2016/01/28/seo-tags-in-phoenix.html](http://blog.danielberkompas.com/2016/01/28/seo-tags-in-phoenix.html)

      iex> Phoenix.HTML.safe_to_string(Scrivener.HTML.SEO.header_links(%Scrivener.Page{total_pages: 10, page_number: 3}))
      "<link href=\"?page=2\" rel=\"prev\"></link>\n<link href=\"?page=4\" rel=\"next\"></link>"
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
    {:safe, [prev, "\n", next]}
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
    content_tag(:link, [], href: href, rel: rel(paginator, paginator.page_number - 1))
  end

  defp next_header_link(conn, paginator, args, opts) do
    href = href(conn, paginator, args, opts, paginator.page_number + 1)
    content_tag(:link, [], href: href, rel: rel(paginator, paginator.page_number + 1))
  end
end
