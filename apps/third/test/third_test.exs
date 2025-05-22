defmodule ThirdTest do
  use ExUnit.Case
  doctest Third

  test "greets the world" do
    assert Third.hello() == :world
  end
end
