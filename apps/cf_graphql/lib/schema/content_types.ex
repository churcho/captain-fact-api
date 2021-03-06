defmodule CF.GraphQL.Schema.ContentTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: DB.Repo

  alias Kaur.Result

  alias CF.GraphQL.Resolvers
  alias DB.Type.VideoHashId

  @default_join_complexity 50

  defmacro join_complexity(complexity \\ @default_join_complexity) do
    quote do
      fn _, child_complexity -> unquote(complexity) + child_complexity end
    end
  end

  object :paginated do
    field(:page_number, :integer)
    field(:page_size, :integer)
    field(:total_pages, :integer)
    field(:total_entries, :integer)
  end

  @desc "Identifies a video. Only Youtube is supported at the moment"
  object :video do
    @desc "Unique identifier as an integer"
    field(:id, non_null(:id))
    @desc "Unique identifier as a hash (min length: 4) - used in URL"
    field(:hash_id, non_null(:string))
    @desc "Video title as extracted from provider"
    field(:title, non_null(:string))
    @desc "Video URL"
    field(:url, non_null(:string), do: resolve(&Resolvers.Videos.url/3))
    @desc "Video provider (youtube, vimeo...etc)"
    field(:provider, non_null(:string))
    @desc "Unique ID used to identify video with provider"
    field(:provider_id, non_null(:string))
    @desc "Language of the video represented as a two letters locale"
    field(:language, :string)
    @desc "List all non-removed speakers for this video"
    field :speakers, list_of(:speaker) do
      resolve(assoc(:speakers))
      complexity(join_complexity())
    end

    @desc "List all non-removed statements for this video"
    field :statements, list_of(:statement) do
      resolve(&Resolvers.Videos.statements/3)
      complexity(join_complexity())
    end
  end

  @desc "A speaker appearing in one or more videos"
  object :speaker do
    field(:id, non_null(:id))
    @desc "A unique slug to identify the speaker"
    field(:slug, :string)
    @desc "Full name"
    field(:full_name, non_null(:string))

    @desc "Official title (can have multiple separated by a comma). Ex: Politician, activist, writer"
    field(:title, :string)
    @desc "Country code of the speaker's origin (from wikidata)"
    field(:country, :string)
    @desc "Wikidata unique identifier, without the 'Q' prefix"
    field(:wikidata_item_id, :string)
    @desc "Speaker's picture URL. Format is 50x50"
    field(:picture, :string, do: resolve(&Resolvers.Speakers.picture/3))
    @desc "List of speaker's videos"
    field :videos, list_of(:video) do
      resolve(assoc(:videos))
      complexity(join_complexity())
    end
  end

  @desc "A transcript or a description of the picture"
  object :statement do
    field(:id, non_null(:id))
    @desc "Speaker's transcript or image description"
    field(:text, non_null(:string))
    @desc "Statement timecode, in seconds"
    field(:time, non_null(:integer))
    @desc "Statement's speaker. Null if statement describes picture"
    field :speaker, :speaker do
      resolve(assoc(:speaker))
      complexity(join_complexity())
    end

    @desc "List of users comments and facts for this statement"
    field :comments, list_of(:comment) do
      resolve(assoc(:comments))
      complexity(join_complexity())
    end
  end

  @desc "A user's comment. A comment will be considered being a fact if it has a source"
  object :comment do
    field(:id, non_null(:id))
    @desc "User who made the comment"
    field :user, :user do
      resolve(assoc(:user))
      complexity(join_complexity())
    end

    @desc "Text of the comment. Can be null if the comment has a source"
    field(:text, :string)
    @desc "Can be true / false (facts) or null (comment)"
    field(:approve, :boolean)
    @desc "Datetime at which the comment has been added"
    field(:inserted_at, :string)
    @desc "Score of the comment / fact, based on users votes"
    field :score, non_null(:integer) do
      resolve(&Resolvers.Comments.score/3)
      complexity(join_complexity())
    end

    @desc "Source of the scomment. If null, a text must be set"
    field :source, :source do
      resolve(assoc(:source))
      complexity(join_complexity())
    end

    @desc "If this comment is a reply, this will point toward the comment being replied to"
    field(:reply_to_id, :id)
  end

  @desc "An URL pointing toward a source (article, video, pdf...)"
  object :source do
    @desc "Unique id of the source"
    field(:id, non_null(:id))
    @desc "URL of the source"
    field(:url, non_null(:string))
    @desc "Title of the page / article"
    field(:title, :string)
    @desc "Language of the page / article"
    field(:language, :string)
    @desc "Site name extracted from OpenGraph"
    field(:site_name, :string)
  end

  @desc "A user registered on the website"
  object :user do
    @desc "Unique user ID"
    field(:id, non_null(:id))
    @desc "Unique username"
    field(:username, non_null(:string))
    @desc "Optional full-name"
    field(:name, :string)
    @desc "Reputation of the user. See https://captainfact.io/help/reputation"
    field(:reputation, :integer)
    @desc "User picture url (96x96)"
    field(:picture_url, non_null(:string), do: resolve(&Resolvers.Users.picture_url/3))
    @desc "Small version of the user picture (48x48)"
    field(:mini_picture_url, non_null(:string), do: resolve(&Resolvers.Users.mini_picture_url/3))
    @desc "A list of user's achievements as a list of integers"
    field(:achievements, list_of(:integer))
    @desc "User's registration datetime"
    field(:registered_at, :string, do: fn u, _, _ -> {:ok, u.inserted_at} end)
    @desc "User activity log"
    field :actions, :activity_log do
      complexity(join_complexity())
      arg(:offset, :integer)
      arg(:limit, :integer)
      resolve(&Resolvers.Users.activity_log/3)
    end
  end

  @desc "Describe a user action"
  object :user_action do
    @desc "Unique action ID"
    field(:id, non_null(:id))
    @desc "User who made the action"
    field :user, :user do
      resolve(assoc(:user))
      complexity(join_complexity())
    end

    @desc "User targeted by the action"
    field :target_user, :user do
      resolve(assoc(:target_user))
      complexity(join_complexity())
    end

    @desc "Actions context"
    field(
      :context,
      :string,
      do:
        resolve(fn
          %{context: "VD:" <> id}, _, _ ->
            Result.ok("VD:" <> VideoHashId.encode(String.to_integer(id)))

          _, _, _ ->
            Result.ok(nil)
        end)
    )

    @desc "Action type"
    field(:type, non_null(:integer))
    @desc "Entity type"
    field(:entity, non_null(:integer))
    @desc "Entity ID"
    field(:entity_id, :integer)
    @desc "Datetime at which the action has been done"
    field(:time, :string, do: resolve(fn a, _, _ -> {:ok, a.inserted_at} end))
    @desc "A map with all the changes made by this action"
    field(
      :changes,
      :string,
      do:
        resolve(fn a, _, _ ->
          {:ok, Poison.encode!(a.changes)}
        end)
    )
  end

  @desc "Information about the application"
  object :app_info do
    @desc "Indicate if the application is running properly with a checkmark"
    field(:status, non_null(:string))
    @desc "GraphQL API version"
    field(:version, non_null(:string))
    @desc "Version of the database app attached to this API"
    field(:db_version, non_null(:string))
  end

  @desc "Statistics about the platform community"
  object :statistics do
    @desc "All totals"
    field(:totals, :statistic_totals, do: resolve(&Resolvers.Statistics.all_totals/3))
    @desc "List the 20 best users"
    field(:leaderboard, list_of(:user), do: resolve(&Resolvers.Statistics.leaderboard/2))
  end

  @desc "Counts for all public CF tables"
  object :statistic_totals do
    field(:users, non_null(:integer))
    field(:comments, non_null(:integer))
    field(:statements, non_null(:integer))
    field(:sources, non_null(:integer))
  end

  @desc "A paginated list of user actions"
  object :activity_log do
    import_fields(:paginated)
    field(:entries, list_of(:user_action))
  end
end
