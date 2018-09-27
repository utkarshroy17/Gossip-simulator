defmodule TWOTest do
  use ExUnit.Case
  doctest TWO

  test "greets the world" do
    assert TWO.hello() == :world
  end
end
