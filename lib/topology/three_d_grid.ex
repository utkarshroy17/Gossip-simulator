defmodule ThreeDGrid do
  def get_3D_neighbor(actor_index, a) do
    x = Float.ceil(RC.nth_root(3, Map.size(actor_index)))
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

    neighbors =
      neighbors ++
        cond do
          rem(y, x * x) >= 0 && rem(y, x * x) < x ->
            [Map.get(actor_index, y + x)]

          rem(y, x * x) >= x * x - x && rem(y, x * x) < x * x ->
            [Map.get(actor_index, y - x)]

          true ->
            [Map.get(actor_index, y + x)] ++ [Map.get(actor_index, y - x)]
        end

    neighbors =
      neighbors ++ [Map.get(actor_index, y + x * x)] ++ [Map.get(actor_index, y - x * x)]

    List.to_tuple(MyList.delete_all(neighbors, nil))
  end

  def findNeighbours(participants) do
    for a <- participants, id = elem(a, 1), data = get_3D_neighbor(participants, a), into: %{} do
      {id, data}
    end
  end
end
