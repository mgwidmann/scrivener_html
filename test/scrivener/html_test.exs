defmodule Scrivener.HTMLTest do
  use Pavlov.Case, async: true
  alias Scrivener.HTML
  import Scrivener.Support.HTML
  alias Scrivener.Page

  describe "raw_pagination_links" do

    describe "for a page" do

      it "in the middle" do
        assert pages(45..55) == links_with_opts total_pages: 100, page_number: 50
      end

      it ":distance from the first" do
        assert pages(1..10) == links_with_opts total_pages: 20, page_number: 5
      end

      it "2 away from the first" do
        assert pages(1..8) == links_with_opts total_pages: 10, page_number: 3
      end

      it "1 away from the first" do
        assert pages(1..7) == links_with_opts total_pages: 10, page_number: 2
      end

      it "at the first" do
        assert pages(1..6) == links_with_opts total_pages: 10, page_number: 1
      end

      it ":distance from the last" do
        assert pages(10..20) == links_with_opts total_pages: 20, page_number: 15
      end

      it "2 away from the last" do
        assert pages(3..10) == links_with_opts total_pages: 10, page_number: 8
      end

      it "1 away from the last" do
        assert pages(4..10) == links_with_opts total_pages: 10, page_number: 9
      end

      it "at the last" do
        assert pages(5..10) == links_with_opts total_pages: 10, page_number: 10
      end

    end

    describe "next" do

      it "includes a next" do
        assert pages_with_next(45..55, 51) == links_with_opts [total_pages: 100, page_number: 50], next: ">>"
      end

      it "does not include next when equal to the total" do
        assert pages(5..10) == links_with_opts [total_pages: 10, page_number: 10], next: ">>"
      end

      it "can disable next" do
        assert pages(45..55) == links_with_opts [total_pages: 100, page_number: 50], next: false
      end

    end

    describe "previous" do

      it "includes a previous" do
        assert pages_with_previous(49, 45..55) == links_with_opts [total_pages: 100, page_number: 50], previous: "<<"
      end

      it "includes a previous before the first" do
        assert [{"<<", 49}] ++ [{1, 1}] ++ pages(45..55) == links_with_opts [total_pages: 100, page_number: 50], previous: "<<", first: true
      end

      it "does not include previous when equal to page 1" do
        assert pages(1..6) == links_with_opts [total_pages: 10, page_number: 1], previous: "<<"
      end

      it "can disable previous" do
        assert pages(45..55) == links_with_opts [total_pages: 100, page_number: 50], previous: false
      end

    end

    describe "first" do

      it "includes the first" do
        assert pages_with_first(1, 5..15) == links_with_opts [total_pages: 20, page_number: 10], first: true
      end

      it "does not the include the first when it is already included" do
        assert pages(1..10) == links_with_opts [total_pages: 10, page_number: 5], first: true
      end

      it "can disable first" do
        assert pages(5..15) == links_with_opts [total_pages: 20, page_number: 10], first: false
      end

    end

    describe "last" do

      it "includes the last" do
        assert pages_with_last(5..15, 20) == links_with_opts [total_pages: 20, page_number: 10], last: true
      end

      it "does not the include the last when it is already included" do
        assert pages(1..10) == links_with_opts [total_pages: 10, page_number: 5], last: true
      end

      it "can disable last" do
        assert pages(5..15) == links_with_opts [total_pages: 20, page_number: 10], last: false
      end

    end

    describe "distance" do

      it "can change the distance" do
        assert pages(1..3) == links_with_opts [total_pages: 3, page_number: 2], distance: 1
      end

      it "does not allow negative distances" do
        assert_raise RuntimeError, "Scrivener.HTML: Distance cannot be less than one.", fn ->
          links_with_opts [total_pages: 10, page_number: 5], distance: -5
        end
      end

    end
  end

  describe "pagination_links" do
    before :each do
      Application.put_env(:scrivener_html, :view_style, :bootstrap)
    end

    it "accepts a paginator and options (same as defaults)" do
      assert {:safe, _html} = HTML.pagination_links(%Page{total_pages: 10, page_number: 5}, view_style: :bootstrap, path: &MyApp.Router.Helpers.post_path/3)
    end

    it "supplies defaults" do
      assert {:safe, _html} = HTML.pagination_links(%Page{total_pages: 10, page_number: 5})
    end

    context "application config" do
      before :each do
        Application.put_env(:scrivener_html, :view_style, :another_style)
      end

      it "uses application config" do
        assert_raise RuntimeError, "Scrivener.HTML: View style :another_style is not a valid view style. Please use one of [:bootstrap, :semantic, :foundation]", fn ->
          HTML.pagination_links(%Page{total_pages: 10, page_number: 5})
        end
      end

    end

    it "allows options in any order" do
      assert {:safe, _html} = HTML.pagination_links(%Page{total_pages: 10, page_number: 5}, view_style: :bootstrap, path: &MyApp.Router.Helpers.post_path/3)
    end

    it "errors for unsupported view styles" do
      assert_raise RuntimeError, fn ->
        HTML.pagination_links(%Page{total_pages: 10, page_number: 5}, view_style: :unknown)
      end
    end

    it "accepts an override action" do
      html = HTML.pagination_links(%Page{total_pages: 10, page_number: 5}, view_style: :bootstrap, action: :edit, path: &MyApp.Router.Helpers.post_path/3)
      assert Phoenix.HTML.safe_to_string(html) =~ ~r(\/posts\/:id\/edit)
    end

    it "accepts an override page param name" do
      html = HTML.pagination_links(%Page{total_pages: 2, page_number: 2}, page_param: :custom_pp)
      assert Phoenix.HTML.safe_to_string(html) =~ ~r(custom_pp=2)
    end
  end

  describe "Phoenix conn()" do
    it "handles no entries" do
      use Phoenix.ConnTest
      Application.put_env(:scrivener_html, :view_style, :bootstrap)
      Application.put_env(:scrivener_html, :routes_helper, MyApp.Router.Helpers)

      assert {:safe, ["<nav>",
                      ["<ul class=\"pagination\">",
                        [["<li class=\"active\">", ["<a>", "1", "</a>"], "</li>"]],
                      "</ul>"],
                    "</nav>"]} =
        HTML.pagination_links(conn(), %Page{entries: [], page_number: 1, page_size: 10, total_entries: 0, total_pages: 0})
    end
  end

  describe "alternative view styles" do
    describe "Semantic UI" do
      it "renders Semantic UI styling" do
        use Phoenix.ConnTest
        Application.put_env(:scrivener_html, :view_style, :semantic)
        Application.put_env(:scrivener_html, :routes_helper, MyApp.Router.Helpers)

        assert {:safe, ["<div class=\"ui pagination menu\">",
                        [["<a class=\"active item\">", "1", "</a>"]],
                      "</div>"]} =
          HTML.pagination_links(conn(), %Page{entries: [], page_number: 1, page_size: 10, total_entries: 0, total_pages: 0})
      end
    end

    describe "Foundation for Sites 6.x" do
      it "renders Foundation for Sites 6.x styling" do
        use Phoenix.ConnTest
        Application.put_env(:scrivener_html, :view_style, :foundation)
        Application.put_env(:scrivener_html, :routes_helper, MyApp.Router.Helpers)

        assert {:safe, ["<ul class=\"pagination\" role=\"pagination\">",
                        [["<li class=\"current\">", ["<span>", "1", "</span>"], "</li>"],
                         ["<li class=\"\">", ["<a>", "2", "</a>"], "</li>"],
                         ["<li class=\"\">", ["<a>", "&gt;&gt;", "</a>"], "</li>"]], "</ul>"]} =
          HTML.pagination_links(conn(), %Page{entries: [], page_number: 1, page_size: 10, total_entries: 20, total_pages: 2})
      end

      it "renders Foundation for Sites 6.x styling with ellipsis" do
        use Phoenix.ConnTest
        Application.put_env(:scrivener_html, :view_style, :foundation)
        Application.put_env(:scrivener_html, :routes_helper, MyApp.Router.Helpers)

        assert {:safe, ["<ul class=\"pagination\" role=\"pagination\">",
                        [["<li class=\"\">", ["<a>", "&lt;&lt;", "</a>"], "</li>"], ["<li class=\"\">", ["<a>", "1", "</a>"], "</li>"], ["<li class=\"\">", ["<a>", "2", "</a>"], "</li>"],
                         ["<li class=\"current\">", ["<span>", "3", "</span>"], "</li>"], ["<li class=\"\">", ["<a>", "4", "</a>"], "</li>"], ["<li class=\"\">", ["<a>", "5", "</a>"], "</li>"],
                         ["<li class=\"\">", ["<a>", "6", "</a>"], "</li>"], ["<li class=\"\">", ["<a>", "7", "</a>"], "</li>"], ["<li class=\"\">", ["<a>", "8", "</a>"], "</li>"],
                         ["<li class=\"ellipsis\">", "", "</li>"], ["<li class=\"\">", ["<a>", "10", "</a>"], "</li>"], ["<li class=\"\">", ["<a>", "&gt;&gt;", "</a>"], "</li>"]], "</ul>"]}

          HTML.pagination_links(conn(), %Page{entries: [], page_number: 3, page_size: 10, total_entries: 100, total_pages: 10}, [] , ellipsis: true)
      end
    end
  end
end
