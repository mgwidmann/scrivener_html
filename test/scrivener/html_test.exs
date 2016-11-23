defmodule Scrivener.HTMLTest do
  use ExUnit.Case
  alias Scrivener.HTML

  import Scrivener.Support.HTML
  alias Scrivener.Page

  describe "raw_pagination_links for a page" do

    test "in the middle" do
      assert pages(45..55) == links_with_opts total_pages: 100, page_number: 50
    end

    test ":distance from the first" do
      assert pages(1..10) == links_with_opts total_pages: 20, page_number: 5
    end

    test "2 away from the first" do
      assert pages(1..8) == links_with_opts total_pages: 10, page_number: 3
    end

    test "1 away from the first" do
      assert pages(1..7) == links_with_opts total_pages: 10, page_number: 2
    end

    test "at the first" do
      assert pages(1..6) == links_with_opts total_pages: 10, page_number: 1
    end

    test ":distance from the last" do
      assert pages(10..20) == links_with_opts total_pages: 20, page_number: 15
    end

    test "2 away from the last" do
      assert pages(3..10) == links_with_opts total_pages: 10, page_number: 8
    end

    test "1 away from the last" do
      assert pages(4..10) == links_with_opts total_pages: 10, page_number: 9
    end

    test "at the last" do
      assert pages(5..10) == links_with_opts total_pages: 10, page_number: 10
    end

  end

  describe "raw_pagination_links next" do

    test "includes a next" do
      assert pages_with_next(45..55, 51) == links_with_opts [total_pages: 100, page_number: 50], next: ">>"
    end

    test "does not include next when equal to the total" do
      assert pages(5..10) == links_with_opts [total_pages: 10, page_number: 10], next: ">>"
    end

    test "can disable next" do
      assert pages(45..55) == links_with_opts [total_pages: 100, page_number: 50], next: false
    end

  end

  describe "raw_pagination_links previous" do

    test "includes a previous" do
      assert pages_with_previous(49, 45..55) == links_with_opts [total_pages: 100, page_number: 50], previous: "<<"
    end

    test "includes a previous before the first" do
      assert [{"<<", 49}, {1, 1}, {:ellipsis, Phoenix.HTML.raw("&hellip;")}] ++ pages(45..55) == links_with_opts [total_pages: 100, page_number: 50], previous: "<<", first: true
    end

    test "does not include previous when equal to page 1" do
      assert pages(1..6) == links_with_opts [total_pages: 10, page_number: 1], previous: "<<"
    end

    test "can disable previous" do
      assert pages(45..55) == links_with_opts [total_pages: 100, page_number: 50], previous: false
    end

  end

  describe "raw_pagination_links first" do

    test "includes the first" do
      assert pages_with_first(1, 5..15) == links_with_opts [total_pages: 20, page_number: 10], first: true
    end

    test "does not the include the first when it is already included" do
      assert pages(1..10) == links_with_opts [total_pages: 10, page_number: 5], first: true
    end

    test "can disable first" do
      assert pages(5..15) == links_with_opts [total_pages: 20, page_number: 10], first: false
    end

  end

  describe "raw_pagination_links last" do

    test "includes the last" do
      assert pages_with_last(5..15, 20) == links_with_opts [total_pages: 20, page_number: 10], last: true
    end

    test "does not the include the last when it is already included" do
      assert pages(1..10) == links_with_opts [total_pages: 10, page_number: 5], last: true
    end

    test "can disable last" do
      assert pages(5..15) == links_with_opts [total_pages: 20, page_number: 10], last: false
    end

  end

  describe "raw_pagination_links distance" do

    test "can change the distance" do
      assert pages(1..3) == links_with_opts [total_pages: 3, page_number: 2], distance: 1
    end

    test "does not allow negative distances" do
      assert_raise RuntimeError, "Scrivener.HTML: Distance cannot be less than one.", fn ->
        links_with_opts [total_pages: 10, page_number: 5], distance: -5
      end
    end

  end

  describe "raw_pagination_links ellipsis" do

    test "includes ellipsis after first" do
      assert [{1, 1}, {:ellipsis, "&hellip;"}] ++ pages(45..55) == links_with_opts [total_pages: 100, page_number: 50], previous: false, first: true, ellipsis: "&hellip;"
    end

    test "includes ellipsis before last" do
      assert pages(5..15) ++ [{:ellipsis, "&hellip;"}, {20, 20}] == links_with_opts [total_pages: 20, page_number: 10], last: true, ellipsis: "&hellip;"
    end

    test "does not include ellipsis on first page" do
      assert pages(1..6) == links_with_opts [total_pages: 8, page_number: 1], first: true, ellipsis: "&hellip;"
    end

    test "uses ellipsis only beyond <distance> of first page" do
      assert pages(1..11) == links_with_opts [total_pages: 20, page_number: 6], first: true, ellipsis: "&hellip;"
      assert [{1, 1}, {:ellipsis, "&hellip;"}] ++ pages(2..12) == links_with_opts [total_pages: 20, page_number: 7], first: true, ellipsis: "&hellip;"
    end

    test "does not include ellipsis on last page" do
      assert pages(15..20) == links_with_opts [total_pages: 20, page_number: 20], last: true, ellipsis: "&hellip;"
    end

    test "uses ellipsis only beyond <distance> of last page" do
      assert pages(10..20) == links_with_opts [total_pages: 20, page_number: 15], last: true, ellipsis: "&hellip;"
      assert pages(9..19) ++ [{:ellipsis, "&hellip;"}, {20, 20}] == links_with_opts [total_pages: 20, page_number: 14], last: true, ellipsis: "&hellip;"
    end

  end

  describe "pagination_links" do
    setup do
      Application.put_env(:scrivener_html, :view_style, :bootstrap)
    end

    test "accepts a paginator and options (same as defaults)" do
      assert {:safe, _html} = HTML.pagination_links(%Page{total_pages: 10, page_number: 5}, view_style: :bootstrap, path: &MyApp.Router.Helpers.post_path/3)
    end

    test "supplies defaults" do
      assert {:safe, _html} = HTML.pagination_links(%Page{total_pages: 10, page_number: 5})
    end

    test "uses application config" do
      Application.put_env(:scrivener_html, :view_style, :another_style)
      assert_raise RuntimeError, "Scrivener.HTML: View style :another_style is not a valid view style. Please use one of [:bootstrap, :semantic, :foundation, :bootstrap_v4]", fn ->
        HTML.pagination_links(%Page{total_pages: 10, page_number: 5})
      end
    end

    test "allows options in any order" do
      assert {:safe, _html} = HTML.pagination_links(%Page{total_pages: 10, page_number: 5}, view_style: :bootstrap, path: &MyApp.Router.Helpers.post_path/3)
    end

    test "errors for unsupported view styles" do
      assert_raise RuntimeError, fn ->
        HTML.pagination_links(%Page{total_pages: 10, page_number: 5}, view_style: :unknown)
      end
    end

    test "accepts an override action" do
      html = HTML.pagination_links(%Page{total_pages: 10, page_number: 5}, view_style: :bootstrap, action: :edit, path: &MyApp.Router.Helpers.post_path/3)
      assert Phoenix.HTML.safe_to_string(html) =~ ~r(\/posts\/:id\/edit)
    end

    test "accepts an override page param name" do
      html = HTML.pagination_links(%Page{total_pages: 2, page_number: 2}, page_param: :custom_pp)
      assert Phoenix.HTML.safe_to_string(html) =~ ~r(custom_pp=2)
    end

    test "allows unicode" do
      html = HTML.pagination_links(%Page{total_pages: 2, page_number: 2}, previous: "«")
      assert Phoenix.HTML.safe_to_string(html) == """
      <nav><ul class=\"pagination\"><li class=\"\"><a class=\"\" href=\"?page=1\">«</a></li><li class=\"\"><a class=\"\" href=\"?page=1\">1</a></li><li class=\"active\"><a class=\"\" href=\"?page=2\">2</a></li></ul></nav>
      """ |> String.trim_trailing
    end

    test "allows using raw" do
      html = HTML.pagination_links(%Page{total_pages: 2, page_number: 2}, previous: Phoenix.HTML.raw("&leftarrow;"))
      assert Phoenix.HTML.safe_to_string(html) == """
      <nav><ul class=\"pagination\"><li class=\"\"><a class=\"\" href=\"?page=1\">&leftarrow;</a></li><li class=\"\"><a class=\"\" href=\"?page=1\">1</a></li><li class=\"active\"><a class=\"\" href=\"?page=2\">2</a></li></ul></nav>
      """ |> String.trim_trailing
    end

    test "accept nested keyword list for additionnal params" do
      html = HTML.pagination_links(%Page{total_pages: 2, page_number: 2}, q: [name: "joe"])
      assert Phoenix.HTML.safe_to_string(html) =~ ~r(q\[name\]=joe)
    end
  end

  describe "Phoenix conn()" do
    test "handles no entries" do
      use Phoenix.ConnTest
      Application.put_env(:scrivener_html, :view_style, :bootstrap)
      Application.put_env(:scrivener_html, :routes_helper, MyApp.Router.Helpers)

      assert {:safe, ["<nav>",
                      ["<ul class=\"pagination\">",
                        [["<li class=\"active\">", ["<a class=\"\">", "1", "</a>"], "</li>"]],
                      "</ul>"],
                    "</nav>"]} =
        HTML.pagination_links(build_conn(), %Page{entries: [], page_number: 1, page_size: 10, total_entries: 0, total_pages: 0})
    end

    test "allows other url parameters" do
      use Phoenix.ConnTest
      Application.put_env(:scrivener_html, :view_style, :bootstrap)
      Application.put_env(:scrivener_html, :routes_helper, MyApp.Router.Helpers)

      assert {:safe, ["<nav>",
                      ["<ul class=\"pagination\">",
                      [["<li class=\"active\">", ["<a class=\"\" href=\"/posts?url_param=param&page=1\">", "1", "</a>"], "</li>"],
                       ["<li class=\"\">", ["<a class=\"\" href=\"/posts?url_param=param&page=2\">", "2", "</a>"], "</li>"],
                       ["<li class=\"\">", ["<a class=\"\" href=\"/posts?url_param=param&page=3\">", "3", "</a>"], "</li>"],
                       ["<li class=\"\">", ["<a class=\"\" href=\"/posts?url_param=param&page=4\">", "4", "</a>"], "</li>"],
                       ["<li class=\"\">", ["<a class=\"\" href=\"/posts?url_param=param&page=5\">", "5", "</a>"], "</li>"],
                       ["<li class=\"\">", ["<a class=\"\" href=\"/posts?url_param=param&page=6\">", "6", "</a>"], "</li>"],
                       ["<li class=\"\">", ["<span class=\"\">", "&hellip;", "</span>"], "</li>"],
                       ["<li class=\"\">", ["<a class=\"\" href=\"/posts?url_param=param&page=20\">", "20", "</a>"], "</li>"],
                       ["<li class=\"\">", ["<a class=\"\" href=\"/posts?url_param=param&page=2\">", "&gt;&gt;", "</a>"], "</li>"]],
                      "</ul>"],
                    "</nav>"]} =
        HTML.pagination_links(build_conn(), %Page{entries: [%{__struct__: Post, some: :object}], page_number: 1, page_size: 10, total_entries: 200, total_pages: 20}, url_param: "param")
    end
  end

  describe "Semantic UI" do
    test "renders Semantic UI styling" do
      use Phoenix.ConnTest
      Application.put_env(:scrivener_html, :view_style, :semantic)
      Application.put_env(:scrivener_html, :routes_helper, MyApp.Router.Helpers)

      assert {:safe, ["<div class=\"ui pagination menu\">",
                      [["<a class=\"active item\">", "1", "</a>"]],
                    "</div>"]} =
        HTML.pagination_links(build_conn(), %Page{entries: [], page_number: 1, page_size: 10, total_entries: 0, total_pages: 0})
    end
  end

  describe "Foundation for Sites 6.x" do
    test "renders Foundation for Sites 6.x styling" do
      use Phoenix.ConnTest
      Application.put_env(:scrivener_html, :view_style, :foundation)
      Application.put_env(:scrivener_html, :routes_helper, MyApp.Router.Helpers)

      assert {:safe, ["<ul class=\"pagination\" role=\"pagination\">",
                      [["<li class=\"current\">", ["<span class=\"\">", "1", "</span>"], "</li>"],
                       ["<li class=\"\">", ["<span class=\"\">", "2", "</span>"], "</li>"],
                       ["<li class=\"\">", ["<span class=\"\">", "&gt;&gt;", "</span>"], "</li>"]], "</ul>"]} =
        HTML.pagination_links(build_conn(), %Page{entries: [], page_number: 1, page_size: 10, total_entries: 20, total_pages: 2})
    end

    test "renders Foundation for Sites 6.x styling with ellipsis" do
      use Phoenix.ConnTest
      Application.put_env(:scrivener_html, :view_style, :foundation)
      Application.put_env(:scrivener_html, :routes_helper, MyApp.Router.Helpers)

      assert {:safe, ["<ul class=\"pagination\" role=\"pagination\">",
                      [["<li class=\"\">", ["<span class=\"\">", "&lt;&lt;", "</span>"], "</li>"],
                       ["<li class=\"\">", ["<span class=\"\">", "1", "</span>"], "</li>"],
                       ["<li class=\"\">", ["<span class=\"\">", "2", "</span>"], "</li>"],
                       ["<li class=\"current\">", ["<span class=\"\">", "3", "</span>"], "</li>"],
                       ["<li class=\"\">", ["<span class=\"\">", "4", "</span>"], "</li>"],
                       ["<li class=\"\">", ["<span class=\"\">", "5", "</span>"], "</li>"],
                       ["<li class=\"\">", ["<span class=\"\">", "6", "</span>"], "</li>"],
                       ["<li class=\"\">", ["<span class=\"\">", "7", "</span>"], "</li>"],
                       ["<li class=\"\">", ["<span class=\"\">", "8", "</span>"], "</li>"],
                       ["<li class=\"ellipsis\">", ["<span class=\"\">", "&hellip;", "</span>"], "</li>"],
                       ["<li class=\"\">", ["<span class=\"\">", "10", "</span>"], "</li>"],
                       ["<li class=\"\">", ["<span class=\"\">", "&gt;&gt;", "</span>"], "</li>"]], "</ul>"]} ==
        HTML.pagination_links(build_conn(), %Page{entries: [], page_number: 3, page_size: 10, total_entries: 100, total_pages: 10}, [], ellipsis: true)
    end
  end

  describe "Bootstrap v4" do
    test "renders bootstrap v4 styling" do
      use Phoenix.ConnTest
      Application.put_env(:scrivener_html, :view_style, :bootstrap_v4)
      Application.put_env(:scrivener_html, :routes_helper, MyApp.Router.Helpers)

      assert {:safe, ["<nav aria-label=\"Page navigation\">",
                      ["<ul class=\"pagination\">",
                       [["<li class=\"active page-item\">", ["<a class=\"page-link\">", "1", "</a>"], "</li>"]],
                       "</ul>"], "</nav>"]} =
        HTML.pagination_links(build_conn(), %Page{entries: [], page_number: 1, page_size: 10, total_entries: 0, total_pages: 0})
    end
  end
end
