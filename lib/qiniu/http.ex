defmodule Qiniu.HTTP do
  @moduledoc false

  def post(url, body, opts \\ []) do
    request(:post, url, body, opts)
  end

  def get(url, opts \\ []) do
    request(:get, url, opts)
  end

  defp request(method, url, opts) do
    request(method, url, "", opts)
  end
  defp request(method, url, body, opts) do
    headers = Keyword.merge(opts[:headers] || [], [
      accept: "application/json",
      # connection: "close",
      user_agent: Qiniu.config[:user_agent],
    ])

    response = case method do
      :get -> HTTPoison.get! url, headers, opts
      :post -> HTTPoison.post! url, body, headers, opts
    end

    if opts[:raw] do
      response
    else
      case Poison.decode(response.body) do
        {:ok, body} -> %{response | body: body}
        _           -> response
      end
    end
  end

  @doc false
  def auth_post(url, body) do
    post url, body, headers: [
      Authorization: "QBox " <> Qiniu.Auth.access_token(url, body)
    ]
  end
end
