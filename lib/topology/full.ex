defmodule Full do
  def get_full_neighbor(actor_index, a) do
    x = Map.size(actor_index)
    y = elem(a, 0)
    neighbors = []

    set_full = fn j ->
      neighbors = neighbors ++ Map.get(actor_index, j-1)
    end

    neighbors = Enum.map(1..x, set_full)
    neighbors = List.delete_at(neighbors, y)
    List.to_tuple(neighbors)
  end

  def findNeighbours(participants) do
    IO.inspect participants
    for a <- participants,
        id = elem(a, 1),
        data = get_full_neighbor(participants, a),
        into: %{} do
      {id, data}
    end
  end
end
