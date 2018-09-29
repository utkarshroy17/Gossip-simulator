defmodule TWO do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def generateParticipants(server, numNodes, topology, algorithm) do
    GenServer.call(server, {:generateParticipants, {numNodes, topology, algorithm}})
  end

  def startRumour(server, rumour) do
    GenServer.cast(server, {:startRumour, {rumour}})
  end

  def startSW(server) do
    GenServer.cast(server, {:startSW, {}})
  end

  ## Server Callbacks
  def init(:ok) do
    {:ok, %{}}
  end

  def generateParticipants1(numNodes, topology, _) do
    # IO.puts("Generating Participants..")
    participants =
      0..(numNodes - 1)
      |> Enum.map(fn index ->
        {:ok, pid} = Participant.start_link(index + 1)
        {index, pid}
      end)
      |> Map.new()

    # IO.inspect(participants)
    neighbours =
      case topology do
        "line" -> Line.findNeighbours(participants)
        "full" -> Full.findNeighbours(participants)
        "3D" -> ThreeDGrid.findNeighbours(participants)
        "rand2D" -> Random2DGrid.findNeighbours(participants)
        "torus" -> Sphere.findNeighbours(participants)
        "impLine" -> ImperfectLine.findNeighbours(participants)
        _ -> raise("Invalid Topology")
      end

    IO.inspect(neighbours)

    neighbours
    |> Enum.map(fn {pid, neighbours} -> Participant.learnNeighbours(pid, neighbours) end)

    %{:participants => participants, :neighbours => neighbours}
    # participants
    # |> Enum.map(fn {index, pid} -> Participant.inspect(pid) end)    
  end

  def startRumour1(rumour, state) do
    # IO.write "startRumour1"; IO.inspect(state)
    Participant.receiveRumour(state.participants[0], rumour)
  end

  def startSW1(state) do
    Participant.receiveSW(state.participants[0], 0, 0)
  end

  def handle_call({:generateParticipants, methodArgs}, _, _) do
    {numNodes, topology, algorithm} = methodArgs
    newState = generateParticipants1(numNodes, topology, algorithm)
    {:reply, :ok, newState}
  end

  def handle_cast({method, methodArgs}, state) do
    case method do
      :startRumour ->
        {rumour} = methodArgs
        startRumour1(rumour, state)
        {:noreply, state}

      :startSW ->
        startSW1(state)
        {:noreply, state}
    end
  end
end

defmodule Sample do
  def start(numNodes, topology, algorithm) do
    {:ok, registry_pid} = TWO.start_link([])
    TWO.generateParticipants(registry_pid, numNodes, topology, algorithm)

    case algorithm do
      "gossip" -> TWO.startRumour(registry_pid, "Hello World")
      "push-sum" -> TWO.startSW(registry_pid)
    end
  end
end
