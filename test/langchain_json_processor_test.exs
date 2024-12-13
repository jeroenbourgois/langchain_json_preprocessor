defmodule LangchainJsonProcessorTest do
  use ExUnit.Case
  doctest LangchainJsonProcessor

  test "greets the world" do
    assert LangchainJsonProcessor.hello() == :world
  end
end
