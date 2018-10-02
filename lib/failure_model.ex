defmodule Failure do
  def failure_model(neighbours, participants, fault) do
    pid = participants |> Map.to_list() |> Enum.map(fn {_, v} -> v end)
    x = Map.size(neighbours)

    if fault > 50 do
      raise "Fault should be less than 50%"
    end

    x = Kernel.trunc(Float.round(fault / 100 * x))
    a = Gen_rand.gen_rand_list(pid, x, [], neighbours)
    neighbours = elem(a, 0)
    rand_node_list = elem(a, 1)
    # IO.inspect(rand_node_list)

    for a <- neighbours,
        id = elem(a, 0),
        data = del_neighbors(elem(a, 1), rand_node_list),
        into: %{} do
      {id, data}
    end
  end

  def del_neighbors(neighbors, rand_node_list) do
    neighbors = Tuple.to_list(neighbors)
    List.to_tuple(neighbors -- rand_node_list)
  end
end
