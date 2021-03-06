defmodule TWO do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def generateParticipants(server, numNodes, topology, algorithm, fault) do
    GenServer.call(server, {:generateParticipants, {numNodes, topology, algorithm, fault}})
  end

  def startRumour(server, rumour) do
    GenServer.cast(server, {:startRumour, {rumour}})
  end

  def startSW(server) do
    GenServer.cast(server, {:startSW, {}})
  end

  def gossipParticipantConverge(server, participant) do
    GenServer.cast(server, {:gossipParticipantConverge, {participant}})
  end

  def psParticipantConverge(server, participant) do
    GenServer.cast(server, {:psParticipantConverge, {participant}})
  end

  def terminateIn(server, seconds) do
    GenServer.cast(server, {:terminateIn, {seconds}})
  end

  ## Server Callbacks
  def init(:ok) do
    {:ok,
     %{
       :start_time => nil,
       :participants => nil,
       :neighbours => nil,
       :gossip_convergence => 0,
       :ps_convergence => 0
     }}
  end

  def generateParticipants1(numNodes, topology, _, fault) do
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

    # IO.inspect(neighbours)

    if fault > 0 do
      neighbours_after_failure = Failure.failure_model(neighbours, participants, fault)
      neighbours_after_failure
      |> Enum.map(fn {pid, neighbours} -> Participant.learnNeighbours(pid, neighbours) end)

      %{:participants => participants, :neighbours => neighbours_after_failure}
    else
      neighbours
      |> Enum.map(fn {pid, neighbours} -> Participant.learnNeighbours(pid, neighbours) end)

      %{:participants => participants, :neighbours => neighbours}
    end
  end

  def handleStartRumour(rumour, state) do
    start_time = Time.utc_now()
    Participant.receiveRumour(state.participants[0], rumour)
    put_in(state.start_time, start_time)
  end

  def handleStartSW(state) do
    start_time = Time.utc_now()
    Participant.receiveSW(state.participants[0], 0, 0)
    put_in(state.start_time, start_time)
  end

  def handleFinish(state) do
    end_time = Time.utc_now()
    IO.write("Finished. Time taken: ")
    IO.inspect(Time.diff(end_time, state.start_time, :microsecond) / 1_000_000)
    state.participants |> Enum.map(fn {_, v} -> Process.exit(v, "Voluntary Termination") end)
    state
  end

  def handleGossipParticipantConverge(_, state) do
    newState = put_in(state.gossip_convergence, state.gossip_convergence + 1)
    num_nodes = map_size(state.participants)
    # IO.puts("Total nodes converged = #{newState.gossip_convergence}/#{num_nodes}")

    if((newState.gossip_convergence > 0.7 * num_nodes) && state.isFaulty == false) do
      handleFinish(newState)
    end

    newState
  end

  def handlePSParticipantConverge(_, state) do
    newState = put_in(state.ps_convergence, state.ps_convergence + 1)
    num_nodes = map_size(state.participants)
    # IO.puts("Total nodes converged = #{newState.ps_convergence}/#{num_nodes}")

    if(newState.ps_convergence == num_nodes) do
      handleFinish(newState)
    end

    newState
  end

  def handle_call({:generateParticipants, methodArgs}, _, state) do
    {numNodes, topology, algorithm, fault} = methodArgs
    isFaulty = if(fault != 0) do
      true
    else
      false
    end
    newState = Map.merge(state, %{isFaulty: isFaulty})
    ret_val = generateParticipants1(numNodes, topology, algorithm, fault)
    {:reply, :ok, Map.merge(newState, ret_val)}
  end

  def handle_cast({method, methodArgs}, state) do
    case method do
      :startRumour ->
        {rumour} = methodArgs
        newState = handleStartRumour(rumour, state)
        {:noreply, newState}

      :startSW ->
        newState = handleStartSW(state)
        {:noreply, newState}

      :gossipParticipantConverge ->
        {participant} = methodArgs
        newState = handleGossipParticipantConverge(participant, state)
        {:noreply, newState}

      :psParticipantConverge ->
        {participant} = methodArgs
        newState = handlePSParticipantConverge(participant, state)
        {:noreply, newState}

      :terminateIn -> 
        {seconds} = methodArgs
        Process.send_after(self(), :finish, (seconds * 1000) )
        {:noreply, state}
        
      :finish ->
        handleFinish(state)
        {:noreply, state}
    end
  end

  def handle_info(:finish, state) do
    IO.puts "Execution Time completed"
    handleFinish(state)
    {:noreply, state}
  end

end

defmodule Sample do
  def start(numNodes, topology, algorithm, fault \\ 0) do
    {:ok, orchestrator_pid} = TWO.start_link([])
    Process.register(orchestrator_pid, :orchestrator)

    TWO.generateParticipants(:orchestrator, numNodes, topology, algorithm, fault)

    if(fault != 0) do
      TWO.terminateIn(:orchestrator, 5)
    end
    case algorithm do
      "gossip" -> TWO.startRumour(:orchestrator, "Hello World")
      "push-sum" -> TWO.startSW(:orchestrator)
    end
  end
end
