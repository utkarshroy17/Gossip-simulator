defmodule ImperfectLine do
  def get_rand_line_neighbor(actor_index, a) do
    x = Map.size(actor_index)
    node = elem(a, 0)
    y = actor_index |> Enum.find(fn {key, val} -> val == node end) |> elem(0)
    rand = Gen_rand.rand_elem(y, x)
    List.to_tuple(Tuple.to_list(elem(a, 1)) ++ [Map.get(actor_index, rand)])
  end

  def findNeighbours(participants) do
    neighbor_map = Line.findNeighbours(participants)

    for a <- neighbor_map,
        id = elem(a, 0),
        data = get_rand_line_neighbor(participants, a),
        into: %{} do
      {id, data}
    end
  end
end
