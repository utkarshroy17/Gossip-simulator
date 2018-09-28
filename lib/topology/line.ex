defmodule Line do
  def findNeighbours(participants) do
    participants
    |> Enum.map(fn {index, pid} ->
      nodeNeighbours =
        if(participants[index - 1] != nil) do
          {participants[index - 1]}
        end || {}

      nodeNeighbours =
        if(participants[index + 1] != nil) do
          Tuple.append(nodeNeighbours, participants[index + 1])
        end || nodeNeighbours

      {pid, nodeNeighbours}
    end)
    |> Map.new()
  end
end
