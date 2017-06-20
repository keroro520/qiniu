defmodule Qiniu.Uploader do
  @moduledoc """
  For uploading.
  """

  alias Qiniu.PutPolicy

  @doc """
  Upload a file directly.
  See http://developer.qiniu.com/docs/v6/api/reference/up/upload.html

  ## Example

      put_policy = %Qiniu.PutPolicy{scope: "books", deadline: 1427990400}
      Qiniu.Uploader.upload put_policy, "~/cool.jpg", key: "cool.jpg"
      # =>
      %HTTPoison.Response{
        body: "body",
        headers: %{"connection" => "keep-alive", "content-length" => "517", ...},
        status_code: 200
      }

  ## Fields

    * `put_policy` - PutPolicy struct
    * `local_file` - path of local file

  ## Options
    * `:key`   - file name in a Qiniu bucket
    * `:crc32` - crc32 to check the file
    * `others` - Custom fields `atom: "string"`, e.g. `foo: "foo", bar: "bar"`
  """

  def upload(put_policy_or_token, local_file_or_data, opts \\ [])

  def upload(%PutPolicy{}=put_policy, local_file_or_data, opts) do
    uptoken = Qiniu.Auth.generate_uptoken(put_policy)

    # https://github.com/benoitc/hackney#send-a-body
    # Name should be string
    opts = Enum.map(opts, fn {k, v} -> {to_string(k), to_string(v)} end)
    upload(uptoken, local_file_or_data, opts)
  end
  def upload(uptoken, {:local_file, local_file}, opts) when is_binary(uptoken) do
    data = List.flatten opts, [{:file, local_file}, {"token", uptoken}]
    post_data = {:multipart, data}

    Qiniu.HTTP.post(Qiniu.config[:up_host], post_data)
  end
  def upload(uptoken, {:data, data}, opts) when is_binary(uptoken) do
    data = List.flatten opts, [{"file", data}, {"token", uptoken}]
    post_data = {:multipart, data}

    Qiniu.HTTP.post(Qiniu.config[:up_host], post_data)
  end
end
