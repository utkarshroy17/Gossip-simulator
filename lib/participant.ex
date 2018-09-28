defmodule Participant do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
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

  # def sendRumour(participant, rumour) do
  #   GenServer.cast(participant, {:sendRumour, {rumour}})
  # end

  #Server APIs
  def init(:ok) do
    {:ok, %{
      :neighbours => {},
      :rumour => %{
        :text => nil,
        :count => 0
      }
    }}
  end

  def handleReceiveRumour(rumour, state) do
    newState = cond do
      state.rumour.text == rumour -> 
        IO.inspect state.rumour.count
        put_in state.rumour.count, state.rumour.count + 1
      state.rumour.text == nil -> put_in state.rumour, %{:text => rumour, :count => 1} 
      true -> raise "Invalid rumour"
    end
    cond do
      newState.rumour.count < 10 ->
        numNeighbours = tuple_size newState.neighbours
        if(numNeighbours == 0) do raise "No neighbours" end
        randomNeighbour = elem(newState.neighbours, :rand.uniform(numNeighbours)-1)
        IO.write "Sending rumour to"; IO.inspect randomNeighbour
        receiveRumour(randomNeighbour, newState.rumour.text)
      true -> IO.puts("finish")
        #Terminate program
    end
    newState
  end

  # def handleSendRumour(state) do
  #   cond do
  #     state.rumour.count < 10 ->
  #       numNeighbours = tuple_size state.neighbours
  #       if(numNeighbours == 0) do raise "No neighbours" end
  #       randomNeighbour = elem(state.neighbours, :rand.uniform(numNeighbours)-1)
  #       IO.write "Sending rumour to"; IO.inspect randomNeighbour
  #       receiveRumour(randomNeighbour, state.rumour.text)
  #     true -> IO.puts("finish")
  #       #Terminate program
  #   end
  # end

  def handle_cast(arg1, state) do
    {method, methodArgs} = arg1
    case method do
      :learnNeighbours -> 
        {neighbours} = methodArgs
        newState = put_in state.neighbours, neighbours
        {:noreply, newState}
      :receiveRumour ->
        {rumour} = methodArgs
        newState = handleReceiveRumour(rumour, state)
        # sendRumour(pid, rumour)
        {:noreply, newState}
      # :sendRumour ->
      #   {rumour} = methodArgs
      #   newState = handleSendRumour(state)
      #   {:noreply, state}
    end
  end

end





# defmodule Participant do
#   use Agent

#   def start_link(_opts) do
#     Agent.start_link(fn -> %{
#       :neighbours => {},
#       :rumour => %{
#         :text => nil,
#         :count => 0
#       }
#     } end)
#     #Send pid to GenServer
#   end

#   def learnNeighbours(participant, neighbours) do
#     # IO.write("learnNeighbours "); IO.inspect(participant); IO.inspect(neighbours)
#     Agent.update(participant, fn state -> 
#       put_in state.neighbours, neighbours
#     end)
#   end

#   # def inspect(participant) do 
#   #   Agent.get(participant, fn state -> IO.inspect state end)
#   # end

#   def receiveRumour(participant, rumour) do
#     IO.write "Rumour received by "; IO.inspect participant    
#     Agent.update(participant, fn state ->
#      cond do
#        state.rumour.text == rumour -> put_in state.rumour.count, state.rumour.count + 1
#        state.rumour.text == nil -> put_in state.rumour, %{:text => rumour, :count => 1} 
#        true -> raise "Invalid rumour"
#      end
#     end)
#     sendRumour(participant)
#   end

#   def sendRumour(participant) do
#     Agent.get(participant, fn state ->
#       cond do
#         state.rumour.count < 10 ->
#           numNeighbours = tuple_size state.neighbours
#           if(numNeighbours == 0) do raise "No neighbours" end
#           randomNeighbour = elem(state.neighbours, :rand.uniform(numNeighbours)-1)
#           IO.write "Sending rumour to"; IO.inspect randomNeighbour
#           receiveRumour(randomNeighbour, state.rumour.text)
#         true -> IO.puts("finish")
#           #Terminate program
#       end
#     end)
#   end
# end