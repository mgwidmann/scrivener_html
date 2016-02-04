defmodule MyApp.Router.Helpers do

  def post_path(_conn, :index, params), do: "/posts#{query_params(params)}"
  def post_path(_conn, :edit, params), do: "/posts/:id/edit#{query_params(params)}"
  def post_comment_path(_conn, :index, post_id, params), do: "/posts/#{post_id}#{query_params(params)}"

  defp query_params(params) do
    Enum.reduce params, "?", fn {k, v}, s ->
      "#{s}#{if(s == "?", do: "", else: "&")}#{k}=#{v}"
    end
  end

end
