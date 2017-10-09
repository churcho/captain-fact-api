defmodule CaptainFactWeb.VideoDebateHistoryChannel do
  use CaptainFactWeb, :channel

  import CaptainFact.VideoDebate.ActionCreator, only: [action_restore: 3]
  import CaptainFactWeb.UserSocket, only: [handle_in_authenticated: 4]

  alias Phoenix.View
  alias Ecto.Multi
  alias CaptainFact.Videos.VideoHashId
  alias CaptainFact.Accounts.UserPermissions
  alias CaptainFactWeb.{ Statement, Speaker, VideoSpeaker, StatementView, SpeakerView }
  alias CaptainFact.VideoDebate.History
  alias CaptainFactWeb.UserActionView


  def join("video_debate_history:" <> video_id_hash, _payload, socket) do
    video_id = VideoHashId.decode!(video_id_hash)
    actions = View.render_many(History.video_debate_history(video_id), UserActionView, "action.json")
    {:ok, %{actions: actions}, assign(socket, :video_id, video_id)}
  end

  def join("statement_history:" <> statement_id, _payload, socket) do
    actions = View.render_many(History.statement_history(statement_id), UserActionView, "action.json")
    {:ok, %{actions: actions}, assign(socket, :statement_id, statement_id)}
  end

  def handle_in(command, params, socket) do
    handle_in_authenticated(command, params, socket, &handle_in_authenticated!/3)
  end

  def handle_in_authenticated!("restore_statement", %{"id" => id}, socket) do
    %{user_id: user_id, video_id: video_id} = socket.assigns
    UserPermissions.check!(user_id, :restore, :statement)
    statement = Repo.get_by!(Statement, id: id, is_removed: true)
    Multi.new
    |> Multi.update(:statement, Statement.changeset_restore(statement))
    |> Multi.run(:action_restore, fn %{statement: statement} ->
         Repo.insert(action_restore(user_id, video_id, statement))
       end)
    |> Repo.transaction()
    |> case do
        {:ok, %{action_restore: action, statement: statement}} ->
          # Broadcast action
          rendered_action =
            action
            |> Map.put(:user, Repo.one!(Ecto.assoc(action, :user)))
            |> View.render_one(UserActionView, "action.json")
          broadcast!(socket, "action_added", rendered_action)

          # Broadcast statement
          CaptainFactWeb.Endpoint.broadcast(
            "statements:video:#{VideoHashId.encode(video_id)}",
            "statement_added",
            StatementView.render("show.json", statement: statement)
          )
          {:reply, :ok, socket}
        {:error, _, reason, _} ->
          IO.inspect(reason)
          {:reply, :error, socket}
    end
  end

  def handle_in_authenticated!("restore_speaker", %{"id" => id}, socket) do
    %{user_id: user_id, video_id: video_id} = socket.assigns
    UserPermissions.check!(user_id, :restore, :speaker)
    speaker = Repo.get(Speaker, id)
    video_speaker = VideoSpeaker.changeset(%VideoSpeaker{speaker_id: speaker.id, video_id: video_id})

    Multi.new
    |> multi_undelete_speaker(speaker)
    |> Multi.insert(:video_speaker, video_speaker)
    |> Multi.insert(:action_restore, action_restore(user_id, video_id, speaker))
    |> Repo.transaction()
    |> case do
      {:ok, %{action_restore: action}} ->
        # Broadcast the action
        rendered_action =
          action
          |> Map.put(:user, Repo.one!(Ecto.assoc(action, :user)))
          |> View.render_one(UserActionView, "action.json")
        broadcast!(socket, "action_added", rendered_action)
        # Broadcast the speaker
        CaptainFactWeb.Endpoint.broadcast(
          "video_debate:#{VideoHashId.encode(video_id)}",
          "speaker_added",
          SpeakerView.render("show.json", speaker: speaker)
        )

        {:reply, :ok, socket}
      {:error, _reason} ->
        {:reply, :error, socket}
    end
  end

  # No need to do nothing if speaker is not user defined (cannot be removed)
  defp multi_undelete_speaker(multi, %{is_user_defined: false}), do: multi
  defp multi_undelete_speaker(multi, speaker) do
    Multi.update(multi, :speaker, Speaker.changeset_restore(speaker))
  end
end
