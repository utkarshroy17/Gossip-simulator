defmodule TWO do

  def generateParticipants(numNodes, topology, algorithm) do
    # IO.puts("Generating Participants..")
    participants = 1..numNodes
      |> Enum.map(fn index -> 
          {:ok, pid} = Participant.start_link([])
          {index, pid}
         end) 
      |> Map.new
    # IO.inspect(participants)
    neighbours = participants
      |> Enum.map(fn {index, pid} -> 
          nodeNeighbours = if(participants[index-1] != nil) do
            {participants[index-1]}
          end || {}
          nodeNeighbours = if(participants[index+1] != nil) do
            Tuple.append(nodeNeighbours, participants[index+1])
          end || nodeNeighbours
          {pid, nodeNeighbours}
         end)
      |> Map.new
    # IO.inspect(neighbours)
    neighbours 
    |> Enum.map(fn {pid, neighbours} -> Participant.learnNeighbours(pid, neighbours) end)

    %{:participants => participants, :neighbours => neighbours}
    # participants
    # |> Enum.map(fn {index, pid} -> Participant.inspect(pid) end)    
  end

  def startRumour(rumour, state) do
    # IO.write "startRumour1"; IO.inspect(state)
    Participant.receiveRumour(state.participants[1], rumour)
  end

  def start(numNodes, topology, algorithm) do
    TWO.generateParticipants(numNodes, topology, algorithm)
    TWO.startRumour("Hello World")
  end
  
end
