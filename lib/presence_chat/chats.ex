defmodule PresenceChat.Chats do
  @moduledoc """
  The Chats context.
  """

  import Ecto.Query, warn: false
  alias PresenceChat.Repo

  alias PresenceChat.Chats.Chat
  alias PresenceChat.Messages.Message

  @default_limit 10
  @default_threshold 4

  @doc """
  Returns the list of chats.

  ## Examples

      iex> list_chats()
      [%Chat{}, ...]

  """
  def list_chats, do: list_chats(%{limit: @default_limit})

  def list_chats(%{limit: size}) do
    chat_with_preload()
    |> order_by(:inserted_at)
    |> limit(^size)
    |> Repo.all()
  end

  def search(query_string) do
    search(query_string, %{threshold: @default_threshold, limit: @default_limit})
  end

  def search(query_string, %{threshold: threshold, limit: size}) do
    query_string = String.downcase(query_string)

    chat_with_preload()
    |> where([c], fragment("levenshtein_less_equal(?, ?, ?) <= ?", c.name, ^query_string, ^threshold, ^threshold))
    |> order_by([c], [fragment("levenshtein_less_equal(?, ?, ?)", c.name, ^query_string, ^threshold), c.name])
    |> limit(^size)
    |> Repo.all()
  end

  defp chat_with_preload do
    Chat
    |> preload([:members, messages: ^(from _ in Message, order_by: [desc: :inserted_at]), messages: :author])
  end

  @doc """
  Gets a single chat.

  Raises `Ecto.NoResultsError` if the Chat does not exist.

  ## Examples

      iex> get_chat!(123)
      %Chat{}

      iex> get_chat!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chat!(id) do
    Chat
    |> where(id: ^id)
    |> preload([:members, messages: ^(from _ in PresenceChat.Messages.Message, order_by: [asc: :inserted_at]), messages: :author])
    |> Repo.one()
  end

  # def join!(chat, user) do
  #   chat
  #   |> Ecto.Changeset.change()
  #   |> Ecto.Changeset.put_assoc(:members, [user | chat.members])
  #   |> Repo.update!()
  # end

  @doc """
  Creates a chat.

  ## Examples

      iex> create_chat(%{field: value})
      {:ok, %Chat{}}

      iex> create_chat(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chat(attrs \\ %{}) do
    %Chat{}
    |> Chat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a chat.

  ## Examples

      iex> update_chat(chat, %{field: new_value})
      {:ok, %Chat{}}

      iex> update_chat(chat, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chat(%Chat{} = chat, attrs) do
    chat
    |> Chat.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Chat.

  ## Examples

      iex> delete_chat(chat)
      {:ok, %Chat{}}

      iex> delete_chat(chat)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chat(%Chat{} = chat) do
    Repo.delete(chat)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chat changes.

  ## Examples

      iex> change_chat(chat)
      %Ecto.Changeset{source: %Chat{}}

  """
  def change_chat(chat \\ %Chat{}, attrs \\ %{})
  def change_chat(%Chat{} = chat, attrs) do
    Chat.changeset(chat, attrs)
  end

  def recent_message(%Chat{} = chat) do
    chat.messages
    |> Repo.one()
  end
end
