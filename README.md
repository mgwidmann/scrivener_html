# Scrivener.Html [![Build Status](https://semaphoreci.com/api/v1/projects/3b1ad27c-8991-4208-94d0-0bae42108482/638637/badge.svg)](https://semaphoreci.com/mgwidmann/scrivener_html)

Helpers built to work with [Scrivener](https://github.com/drewolson/scrivener)'s page struct to easily build HTML output for various CSS frameworks.

## Setup

Add to `mix.exs`

```elixir
  # add :scrivener_html to deps
  defp deps do
    [
      # ...
      {:scrivener_html, "~> 1.1"}
      # ...
    ]
  end

  # add :scrivener_html to applications list
  defp application do
    [
      # ...
      applications: [ ..., :scrivener_html, ... ]
      # ...
    ]
  end
```

For use with Phoenix.HTML, configure the `:routes_helper` module in `config/config.exs`
like the following:

```elixir
config :scrivener_html,
  routes_helper: MyApp.Router.Helpers
```

Import to your view.

```elixir
defmodule MyApp.UserView do
  use MyApp.Web, :view
  import Scrivener.HTML
end
```

## Example Usage

Use in your template.

```elixir
<%= for user <- @page.entries do %>
   ...
<% end %>

<%= pagination_links @page %>
```

Where `@page` is a `%Scrivener.Page{}` struct returned from `Repo.paginate/2`.
So the function in your controller is like:

```elixir
#  params = %{"page" => _page}
def index(conn, params) do
  page = MyApp.User
          # Other query conditions can be done here
          |> MyApp.Repo.paginate(params)
  render conn, :index, page: page
end
```

### Scopes and URL Parameters

If your resource has any url parameters to be supplied, you should provide them as the 3rd parameter. For example, given a scope like:

```elixir
scope "/:locale", App do
  pipe_through [:browser]

  get "/page", PageController, :index, as: :pages
  get "/pages/:id", PageController, :show, as: :page
end
```

You would need to pass in the `:locale` parameter and `:path` option like so:

```elixir
<%= pagination_links @page, ["en"], path: &pages_path/4 %>
```

With a nested resource, simply add it to the list:

```elixir
<%= pagination_links @page, ["en", @page_id], path: &page_path/4, action: :show %>
```

#### Query String Parameters

Any additional query string parameters can be passed in as well.

```elixir
<%= pagination_links @page, ["en"], some_parameter: "data" %>
<%# OR IF NO URL PARAMETERS %>
<%= pagination_links @page, some_parameter: "data" %>
```

### Custom Actions

If you need to hit a different action other than `:index`, simply pass the action name to use in the url helper.

```elixir
<%= pagination_links @page, action: :show %>
```

## Customizing Output

Below are the defaults which are used without passing in any options.

```elixir
<%= pagination_links @page, distance: 5, next: ">>", previous: "<<", first: true, last: true, view_style: :bootstrap %>
```

To prevent HTML escaping (i.e. seeing things like `&lt;` on the page), simply use `Phoenix.HTML.raw/1` for any `&amp;` strings passed in, like so:

```elixir
<%= pagination_links @page, previous: Phoenix.HTML.raw("&leftarrow;"), next: Phoenix.HTML.raw("&rightarrow;") %>
```

To show icons instead of text, simply render custom html templates, like:

<%= pagination_links @page, render(MyPhoenixApp.MyView, "prev_link.html", []), next: render(MyPhoenixApp.MyView, "next_link.html", []) %>

And in prev_link.html.eex (this example use materialize icons)
<i class="material-icons">chevron_left</i>

There are five view styles currently supported:

- `:bootstrap` (the default) This styles the pagination links in a manner that
  is expected by Bootstrap 3.x.
- `:foundation` This styles the pagination links in a manner that is expected
  by Foundation for Sites 6.x.
- `:semantic` This styles the pagination links in a manner that is expected by
  Semantic UI 2.x.
- `:bootstrap_v4` This styles the pagination links in a manner that
  is expected by Bootstrap 4.x.
- `:materialize` This styles the pagination links in a manner that
  is expected by Materialize css 0.x.

For custom HTML output, see `Scrivener.HTML.raw_pagination_links/2`.

See `Scrivener.HTML.raw_pagination_links/2` for option descriptions.

Scrivener.HTML can be included in your view and then just used with a simple call to `pagination_links/1`.

```elixir
iex> Scrivener.HTML.pagination_links(%Scrivener.Page{total_pages: 10, page_number: 5})
{:safe,
  ["<nav>",
    ["<ul class=\"pagination\">",
      [["<li>", ["<a class=\"\" href=\"?page=4\">", "&lt;&lt;", "</a>"], "</li>"],
      ["<li>", ["<a class=\"\" href=\"?page=1\">", "1", "</a>"], "</li>"],
      ["<li>", ["<a class=\"\" href=\"?page=2\">", "2", "</a>"], "</li>"],
      ["<li>", ["<a class=\"\" href=\"?page=3\">", "3", "</a>"], "</li>"],
      ["<li>", ["<a class=\"\" href=\"?page=4\">", "4", "</a>"], "</li>"],
      ["<li>", ["<a class=\"active\" href=\"?page=5\">", "5", "</a>"], "</li>"],
      ["<li>", ["<a class=\"\" href=\"?page=6\">", "6", "</a>"], "</li>"],
      ["<li>", ["<a class=\"\" href=\"?page=7\">", "7", "</a>"], "</li>"],
      ["<li>", ["<a class=\"\" href=\"?page=8\">", "8", "</a>"], "</li>"],
      ["<li>", ["<a class=\"\" href=\"?page=9\">", "9", "</a>"], "</li>"],
      ["<li>", ["<a class=\"\" href=\"?page=10\">", "10", "</a>"], "</li>"],
      ["<li>", ["<a class=\"\" href=\"?page=6\">", "&gt;&gt;", "</a>"], "</li>"]],
      "</ul>"], "</nav>"]}
```
