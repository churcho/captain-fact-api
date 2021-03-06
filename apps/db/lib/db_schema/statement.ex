defmodule DB.Schema.Statement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "statements" do
    field(:text, :string)
    field(:time, :integer)
    field(:is_removed, :boolean, default: false)

    belongs_to(:video, DB.Schema.Video)
    belongs_to(:speaker, DB.Schema.Speaker)

    has_many(:comments, DB.Schema.Comment, on_delete: :delete_all)

    timestamps()
  end

  @required_fields ~w(text time video_id)a
  @optional_fields ~w(speaker_id)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_number(:time, greater_than_or_equal_to: 0)
    |> validate_length(:text, min: 10, max: 255)
    |> cast_assoc(:speaker)
  end

  @doc """
  Builds a deletion changeset for `struct`
  """
  def changeset_remove(struct) do
    cast(struct, %{is_removed: true}, [:is_removed])
  end

  @doc """
  Builds a restore changeset for `struct`
  """
  def changeset_restore(struct) do
    cast(struct, %{is_removed: false}, [:is_removed])
  end
end
