defmodule PresenceChatWeb.SearchChatsView do
  use PresenceChatWeb, :view

  def elipses(true), do: "..."
  def elipses(false), do: nil

  def initials(user) do
    [user.first_name, user.last_name]
    |> Enum.map(&(String.first(&1) |> String.capitalize()))
  end

  def full_name(user) do
    "#{user.first_name} #{user.last_name}"
  end

  def avatar_image_url(user), do: avatar_image_url(user, [size: 50])
  def avatar_image_url(user, [size: size]) do
    "https://robohash.org/#{user.first_name}_#{user.last_name}.jpg?bgset=bg2&size=#{size}x#{size}"
  end

  def format_datetime(i) do
    NaiveDateTime.to_string(i)
  end

  def status_class(users, user) do
    case find_user(users, user) do
      %{away: false} ->
        "online"

      %{away: true} ->
        "away"

      _ ->
        "offline"
    end
  end

  def typing_class(users, user) do
    case find_user(users, user) do
      %{typing: true} ->
        "typing"

      _ ->
        ""
    end
  end

  def find_user(users, user) do
    Enum.find(users, fn o ->
      case user do
        %{user_id: _} = user ->
          o.user_id == user.user_id

        user ->
          o.user_id == user.id
      end
    end)
  end

  def sorted_chat_users(chat, users) do
    online_members = Enum.filter(chat.members, fn member -> status_class(users, member) == "online" end)
    online_visitors = Enum.reject(users, fn user -> user.away || Enum.any?(online_members, fn member -> member.id == user.user_id end) end)
    away_members = Enum.filter(chat.members, fn member -> status_class(users, member) == "away" end)
    away_visitors = Enum.reject(users, fn user -> !user.away || Enum.any?(chat.members, fn member -> member.id == user.user_id end) end)
    offline_members = Enum.filter(chat.members, fn member -> status_class(users, member) == "offline" end)

    online_members ++ online_visitors ++ away_members ++ away_visitors ++ offline_members
  end
end
