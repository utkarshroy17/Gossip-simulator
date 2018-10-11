defmodule Participant do
  use GenServer

  def start_link(count) do
    GenServer.start_link(__MODULE__, count, [])
  end

  def learnNeighbours(participant, neighbours) do
    GenServer.cast(participant, {:learnNeighbours, {neighbours}})
  end

  def inspect(participant) do
    GenServer.call(participant, {:inspect})
  end

  def receiveRumour(participant, rumour) do
    GenServer.cast(participant, {:receiveRumour, {rumour}})
  end

  def receiveSW(participant, s, w) do
    GenServer.cast(participant, {:receiveSW, {s, w}})
  end

  # Server APIs
  def init(count) do
    {:ok,
     %{
       :index => count,
       :neighbours => {},
       :is_transmitting => false,
       :has_converged => false,
       :rumour => %{
         :text => nil,
         :count => 0
       },
       :sw => %{
         :s => count,
         :w => 1,
         :ratios => FourQueue.new()
       }
     }}
  end

  def handleReceiveRumour(rumour, state) do
    newState =
      cond do
        state.rumour.text == rumour ->
          put_in(state.rumour.count, state.rumour.count + 1)

        state.rumour.text == nil ->
          sendRumour(rumour, state.neighbours)

          Map.merge(state, %{:rumour => %{:text => rumour, :count => 1}, :is_transmitting => true})

        true ->
          raise "Invalid rumour"
      end

    if(newState.rumour.count == 10) do
      TWO.gossipParticipantConverge(:orchestrator, state.sw.s)
      # IO.puts "#{state.index} has converged"
      put_in(newState.has_converged, true)
    else
      newState
    end
  end

  def sendRumour(rumour, neighbours) do
    numNeighbours = tuple_size(neighbours)

    if(numNeighbours == 0) do
      raise "No neighbours"
    end

    randomNeighbour = elem(neighbours, :rand.uniform(numNeighbours) - 1)
    receiveRumour(randomNeighbour, rumour)
    Process.send_after(self(), :gossip, 50)
  end

  # Sends message only on receive. Not periodic
  # Not stopping transmission on covergence
  def handleReceiveSW(s, w, state) do
    # IO.write "handleReceiveSW"; IO.inspect state
    newS = (state.sw.s + s) / 2
    newW = (state.sw.w + w) / 2
    newRatios = FourQueue.push(state.sw.ratios, newS / newW)

    newState =
      put_in(state.sw, %{
        :s => newS,
        :w => newW,
        :ratios => newRatios
      })

    diff = FourQueue.diff(newState.sw.ratios)

    newState =
      if diff < :math.pow(10, -10) && state.has_converged == false do
        # IO.puts("#{state.index} has converged")
        TWO.psParticipantConverge(:orchestrator, state.sw.s)
        put_in(newState.has_converged, true)
      else
        newState
      end

    numNeighbours = tuple_size(newState.neighbours)

    if(numNeighbours == 0) do
      raise "No neighbours"
    end

    randomNeighbour = elem(newState.neighbours, :rand.uniform(numNeighbours) - 1)
    # IO.write("Sending SW to"); IO.inspect(randomNeighbour)
    receiveSW(randomNeighbour, newState.sw.s, newState.sw.w)

    newState
  end

  def handle_cast(arg1, state) do
    {method, methodArgs} = arg1

    case method do
      :learnNeighbours ->
        {neighbours} = methodArgs
        newState = put_in(state.neighbours, neighbours)
        {:noreply, newState}

      :receiveRumour ->
        {rumour} = methodArgs
        newState = handleReceiveRumour(rumour, state)
        {:noreply, newState}

      :receiveSW ->
        {s, w} = methodArgs
        newState = handleReceiveSW(s, w, state)
        {:noreply, newState}
    end
  end

  def handle_info(:gossip, state) do
    if(state.has_converged == false) do
      # IO.puts "#{state.index} is gossiping..."
      sendRumour(state.rumour.text, state.neighbours)
    end

    {:noreply, state}
  end
end
