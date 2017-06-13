defmodule Qiniu.Resumer do
  @moduledoc """
  For Resume uploading.
  """

  alias Qiniu.HTTP
  alias Qiniu.PutPolicy

  def mkblk(%PutPolicy{}=put_policy, block_size, first_chunk, opts \\ []) do
    post(mkblk_uri(block_size), put_policy, first_chunk, opts)
  end

  def bput(%PutPolicy{}=put_policy, ctx, offset, next_chunk, opts \\ []) do
    post(bput_uri(ctx, offset), put_policy, next_chunk, opts)
  end

  def mkfile(%PutPolicy{}=put_policy, file_size, ctx_list, opts \\ []) do
    post(mkfile_uri(file_size, opts), put_policy, ctx_list, opts)
  end

  defp post(uri, put_policy, chunk, opts) do
    uptoken = Qiniu.Auth.generate_uptoken(put_policy)
    headers = [
      content_type: "application/octet-stream",
      authorization: "UpToken " <> uptoken,
    ]

    HTTP.post(uri, chunk, [headers: headers], opts)
  end

  defp mkblk_uri(block_size) do
    Qiniu.config[:up_host] <> "/mkblk/#{block_size}"
  end

  defp bput_uri(ctx, offset) do
    Qiniu.config[:up_host] <> "/bput/#{ctx}/#{offset}"
  end

  defp mkfile_uri(file_size, opts)  do
    path = Qiniu.config[:up_host] <> "/mkfile/#{file_size}"

    if key = opts[:key],             do: path = path <> "/key/#{Base.url_encode64(key)}"
    if mime_type = opts[:mime_type], do: path = path <> "/mimeType/#{mime_type}"
    if user_vars = opts[:user_vars], do: path = path <> "/x:user-var/#{user_vars}"
    path
  end
end
