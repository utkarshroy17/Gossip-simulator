defmodule Random2DGrid do
  def get_2D_neighbor(actor_index, a) do
    x = Float.ceil(:math.sqrt(Map.size(actor_index)))
    x = Kernel.trunc(x)
    y = elem(a, 0)

    neighbors =
      cond do
        rem(y, x) == 0 ->
          [Map.get(actor_index, y + 1)]

        rem(y, x) == x - 1 ->
          [Map.get(actor_index, y - 1)]

        true ->
          [Map.get(actor_index, y + 1)] ++ [Map.get(actor_index, y - 1)]
      end

    neighbors = neighbors ++ [Map.get(actor_index, y + x)] ++ [Map.get(actor_index, y - x)]
    List.to_tuple(MyList.delete_all(neighbors, nil))
  end

  def findNeighbours(participants) do
    pid = participants |> Map.to_list() |> Enum.map(fn {k, v} -> v end)

    n = Enum.count(pid)
    x = Kernel.trunc(Float.ceil(:math.sqrt(n)))
    x = x * x
    pid = pid ++ List.duplicate(nil, x - n)

    actor_index =
      Stream.with_index(Enum.shuffle(pid), 0)
      |> Enum.reduce(%{}, fn {v, k}, acc -> Map.put(acc, k, v) end)

    for a <- actor_index, id = elem(a, 1), data = get_2D_neighbor(actor_index, a), into: %{} do
      {id, data}
    end
  end
end
