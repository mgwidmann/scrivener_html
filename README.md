# Scrivener.Html

Helpers built to work with [Scrivener](https://github.com/drewolson/scrivener)'s page struct to easily build HTML output for various CSS frameworks.

## Example Usage

Scrivener.HTML can be included in your view and then just used with a simple call to `pagination_links/1`.

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
