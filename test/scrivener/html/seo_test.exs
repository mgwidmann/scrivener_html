defmodule Scrivener.HTML.SEOTest do
  use ExUnit.Case
  import Scrivener.HTML.SEO
  doctest Scrivener.HTML.SEO

  describe "#rel" do
    test "on the first page - page 2" do
      assert rel(%Scrivener.Page{total_pages: 10, page_number: 1}, 2) == "next"
    end

    test "on the first page - page 5" do
      assert rel(%Scrivener.Page{total_pages: 10, page_number: 1}, 5) == "canonical"
    end

    test "on the third page - page 4" do
      assert rel(%Scrivener.Page{total_pages: 10, page_number: 3}, 4) == "next"
    end

    test "on the third page - page 2" do
      assert rel(%Scrivener.Page{total_pages: 10, page_number: 3}, 2) == "prev"
    end

    test "on the last page - page 9" do
      assert rel(%Scrivener.Page{total_pages: 10, page_number: 10}, 9) == "prev"
    end
  end

  describe "#header_links" do
    test "on the first page" do
      assert header_links(%Scrivener.Page{total_pages: 10, page_number: 1}) ==
               {:safe,
                [
                  60,
                  "link",
                  [32, "href", 61, 34, "?page=2", 34, 32, "rel", 61, 34, "next", 34],
                  62,
                  [],
                  60,
                  47,
                  "link",
                  62
                ]}
    end

    test "on the last page" do
      assert header_links(%Scrivener.Page{total_pages: 10, page_number: 10}) ==
               {:safe,
                [
                  60,
                  "link",
                  [32, "href", 61, 34, "?page=9", 34, 32, "rel", 61, 34, "prev", 34],
                  62,
                  [],
                  60,
                  47,
                  "link",
                  62
                ]}
    end

    test "on a middle page" do
      assert header_links(%Scrivener.Page{total_pages: 10, page_number: 5}) ==
               {
                 :safe,
                 [
                   [
                     60,
                     "link",
                     [32, "href", 61, 34, "?page=4", 34, 32, "rel", 61, 34, "prev", 34],
                     62,
                     [],
                     60,
                     47,
                     "link",
                     62
                   ],
                   "\n",
                   [
                     60,
                     "link",
                     [32, "href", 61, 34, "?page=6", 34, 32, "rel", 61, 34, "next", 34],
                     62,
                     [],
                     60,
                     47,
                     "link",
                     62
                   ]
                 ]
               }
    end
  end
end
