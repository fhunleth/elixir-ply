defmodule PlyTest do
  use ExUnit.Case
  doctest Ply

  test "greets the world" do
    assert Ply.hello() == :world
  end
end
