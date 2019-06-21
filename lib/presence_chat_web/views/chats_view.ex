defmodule PresenceChatWeb.ChatsView do
  use PresenceChatWeb, :view

  def elipses(true), do: "..."
  def elipses(false), do: nil
end
