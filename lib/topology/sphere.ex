defmodule Sphere do
  def get_torus_neighbor(actor_index, a) do
    neighbors = Tuple.to_list(Random2DGrid.get_2D_neighbor(actor_index, a))
    x = Float.ceil(:math.sqrt(Map.size(actor_index)))
    x = Kernel.trunc(x)
    y = elem(a, 0)

    neighbors =
      neighbors ++
        cond do
          rem(y, x) == 0 ->
            [Map.get(actor_index, y + x - 1)]

          rem(y, x) == x - 1 ->
            [Map.get(actor_index, y - x + 1)]

          true ->
            [nil]
        end

    neighbors =
      neighbors ++
        cond do
          y >= 0 && y < x ->
            [Map.get(actor_index, y + (x - 1) * x)]

          y >= x * x - x && y < x * x ->
            [Map.get(actor_index, y - (x - 1) * x)]

          true ->
            [nil]
        end

    List.to_tuple(MyList.delete_all(neighbors, nil))
  end

  def findNeighbours(participants) do
    for a <- participants,
        id = elem(a, 1),
        data = get_torus_neighbor(participants, a),
        into: %{} do
      {id, data}
    end
  end
end
