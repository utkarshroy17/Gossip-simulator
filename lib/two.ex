



# [numNodes, topology, algorithm] = System.argv()
# {numNodes, ""} = Integer.parse(numNodes)

# numNodes = 5
# topology = "line"
# algorithm = "gossip"



#============================================================================================================
defmodule TWO do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def generateParticipants(server, numNodes, topology, algorithm)do
    GenServer.call(server, {:generateParticipants, {numNodes, topology, algorithm}})
  end

  def startRumour(server, rumour) do
    GenServer.call(server, {:startRumour, {rumour}})  
  end

  ## Server Callbacks
  def init(:ok) do
    {:ok, %{}}
  end

  def generateParticipants1(numNodes, topology, algorithm) do
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

  def startRumour1(rumour, state) do
    # IO.write "startRumour1"; IO.inspect(state)
    Participant.receiveRumour(state.participants[1], rumour)
  end

  def handle_call(arg1, _from, state) do
    {method, methodArgs} = arg1
    case method do
      :generateParticipants -> 
        {numNodes, topology, algorithm} = methodArgs
        newState = generateParticipants1(numNodes, topology, algorithm)
        {:reply, :ok, newState}
      :startRumour -> 
        {rumour} = methodArgs
        startRumour1(rumour, state)
        {:reply, :ok, state}
    end
  end

  # def handle_call({:lookup, name}, _from, names) do
  #   {:reply, Map.fetch(names, name), names}
  # end

end

defmodule Sample do
  def start(numNodes, topology, algorithm) do
    {:ok, registry_pid} = TWO.start_link([])
    TWO.generateParticipants(registry_pid, numNodes, topology, algorithm)
    TWO.startRumour(registry_pid, "Hello World")
  end
end

