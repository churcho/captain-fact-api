defmodule CaptainFactWeb.UserSocket do
  use Phoenix.Socket

  require Logger
  import Guardian.Phoenix.Socket
  alias CaptainFactWeb.ErrorView
  alias CaptainFact.Accounts.UserPermissions

  ## Channels
  channel "video_debate:*", CaptainFactWeb.VideoDebateChannel
  channel "video_debate_history:*", CaptainFactWeb.VideoDebateHistoryChannel
  channel "statements_history:*", CaptainFactWeb.VideoDebateHistoryChannel
  channel "statements:video:*", CaptainFactWeb.StatementsChannel
  channel "comments:video:*", CaptainFactWeb.CommentsChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket

  def connect(%{"token" => token}, socket) do
    case sign_in(socket, token) do
      {:ok, authed_socket, _guardian_params} ->
        user_id = case Guardian.Phoenix.Socket.current_resource(authed_socket) do
          nil -> nil
          user -> user.id
        end
        {:ok, assign(authed_socket, :user_id, user_id)}
      _ ->
        {:ok, assign(socket, :user_id, nil)}
    end
  end

  def handle_in_authenticated(command, params, socket, handler) do
    case socket.assigns.user_id do
      nil -> {:reply, :error, socket}
      _ -> rescue_handler(handler, command, params, socket)
    end
  end

  def rescue_handler(handler, command, params, socket) do
    try do
      handler.(command, params, socket)
    catch
      %UserPermissions.PermissionsError{} = e ->
        reply_error(socket, Phoenix.View.render(ErrorView, "403.json", %{reason: e}))
      e ->
        Logger.error("[RescueChannel] Uncatched exception : #{inspect(e)}")
        reply_error(socket, Phoenix.View.render(ErrorView, "error.json", []))
    rescue
      _ in Ecto.NoResultsError ->
        reply_error(socket, Phoenix.View.render(ErrorView, "404.json", []))
      e ->
        Logger.error("[RescueChannel] An unknown error just popped : #{inspect(e)}")
        reply_error(socket, Phoenix.View.render(ErrorView, "error.json", []))
    end
  end

  def id(_socket), do: nil

  defp reply_error(socket, error) do
    {:reply, {:error, error}, socket}
  end
end
