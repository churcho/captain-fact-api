defmodule CF.Opengraph.Router do
  use Plug.Router
  alias DB.Repo
  alias DB.Schema.Video
  alias Kaur.Result
  alias CF.Opengraph.Generator
  require Logger

  plug(Plug.Logger, log: :debug)
  plug(:match)
  plug(:dispatch)

  def start_link(port) do
    success_logging = fn _ ->
      Logger.info("Running CF.Opengraph.Router with cowboy on port #{port}")
    end

    failure_logging = fn error ->
      Logger.error("Unable to start CF.Opengraph router : #{error}")
    end

    Plug.Adapters.Cowboy.http(__MODULE__, [], port: port)
    |> Result.tap(success_logging)
    |> Result.tap_error(failure_logging)
  end

  get "/u/:username" do
    username = conn.params["username"]

    user =
      DB.Schema.User
      |> DB.Repo.get_by(username: username)

    if is_nil(user) do
      send_resp(conn, 404, "not_found")
    else
      user
      |> Generator.render_user(conn.request_path)
      |> (fn body ->
            conn
            |> put_resp_content_type("text/html")
            |> send_resp(200, body)
          end).()
    end
  end

  get "/videos" do
    body = Generator.render_videos_list(conn.request_path)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, body)
  end

  get "/videos/:video_id/*_" do
    conn.params["video_id"]
    |> DB.Type.VideoHashId.decode()
    |> Result.map(fn id -> Repo.get(Video, id) end)
    |> Result.and_then(&Result.from_value/1)
    |> Result.map(&Generator.render_video(&1, conn.request_path))
    |> Result.either(
      fn error ->
        case error do
          :no_value ->
            send_resp(conn, 404, "content not found")

          _ ->
            send_resp(conn, 500, "there has been an unexpected error")
        end
      end,
      fn body ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, body)
      end
    )
  end

  get "/s/:slug_or_id" do
    slug = conn.params[:slug_or_id]

    slug
    |> Integer.parse()
    |> case do
      # If integer parsing succeed it's an ID
      {id, ""} ->
        Speaker
        |> Repo.get(id)

      # Otherwise it's a slug
      _ ->
        Speaker
        |> Repo.get_by(slug: slug)
    end
    |> Result.from_value()
    |> Result.map(&Generator.render_speaker(&1, conn.request_path))
    |> Result.either(
      fn error ->
        case error do
          :no_value -> send_resp(conn, 404, "content not found")
          _ -> send_resp(conn, 500, "there has been an unexpected error")
        end
      end,
      fn body ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, body)
      end
    )
  end

  match _ do
    conn
    |> send_resp(404, "NOT FOUND")
  end
end
