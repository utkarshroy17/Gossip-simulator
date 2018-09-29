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
    GenServer.cast(participant, {:receiveSW, {s,w}})  
  end

  # Server APIs
  def init(count) do
    {:ok,
     %{
       :neighbours => {},
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
    IO.write("handleReceiveRumour"); IO.inspect(state)
    newState =
      cond do
        state.rumour.text == rumour ->
          IO.inspect(state.rumour.count)
          put_in(state.rumour.count, state.rumour.count + 1)

        state.rumour.text == nil ->
          put_in(state.rumour, %{:text => rumour, :count => 1})

        true ->
          raise "Invalid rumour"
      end

    cond do
      newState.rumour.count < 10 ->
        numNeighbours = tuple_size(newState.neighbours)

        if(numNeighbours == 0) do
          raise "No neighbours"
        end

        randomNeighbour = elem(newState.neighbours, :rand.uniform(numNeighbours) - 1)
        IO.write("Sending rumour to"); IO.inspect(randomNeighbour)
        receiveRumour(randomNeighbour, newState.rumour.text)

      true ->
        IO.puts("finish")
        # Terminate program
    end

    newState
  end

  def handleReceiveSW(s, w, state) do
    IO.write "handleReceiveSW #{s}, #{w}, "; IO.inspect state
    newS = (state.sw.s + s)/2
    newW = (state.sw.w + w)/2
    newRatios = FourQueue.push(state.sw.ratios, newS/newW)
    newState = put_in(state.sw, %{
      :s => newS,
      :w => newW,
      :ratios => newRatios
    })
    if (FourQueue.diff(newState.sw.ratios) < :math.pow(10,-10)) do
      IO.puts("finish")
    else
      numNeighbours = tuple_size(newState.neighbours)
      if(numNeighbours == 0) do
        raise "No neighbours"
      end
      randomNeighbour = elem(newState.neighbours, :rand.uniform(numNeighbours) - 1)
      IO.write("Sending SW to"); IO.inspect(randomNeighbour)
      receiveSW(randomNeighbour, newState.sw.s, newState.sw.w)
    end
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
end