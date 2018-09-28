# defmodule Participant do
#   use GenServer

#   def start_link(opts) do
#     GenServer.start_link(__MODULE, :ok, opts)
#   end

#   def learnNeighbours(participant, neighbours) do
#     GenServer.call(participant, {:learnNeighbours, {neighbours}})
#   end

#   def inspect(participant) do
#     GenServer.call(participant, {:inspect, {}})
#   end

#   def receiveRumour(participant, rumour) do
#     GenServer.call(participant, {:receiveRumour, {rumour}})
#   end

#   def sendRumour(participant, rumour) do
#     GenServer.call(participant, {:sendRumour, {rumour}})
#   end

#   #Server APIs
#   def init(:ok) do
#     {:ok, %{
#       :neighbours => {},
#       :rumour => %{
#         :text => nil,
#         :count => 0
#       }
#     }}
#   end


#   def handleReceiveRumour(rumour, state) do
#     cond do
#       state.rumour.text == rumour -> put_in state.rumour.count, state.rumour.count + 1
#       state.rumour.text == nil -> put_in state.rumour, %{:text => rumour, :count => 1} 
#       true -> raise "Invalid rumour"
#     end
#   end

#   def handleSendRumour(state) do
#     cond do
#       state.rumour.count < 10 ->
#         numNeighbours = tuple_size state.neighbours
#         if(numNeighbours == 0) do raise "No neighbours" end
#         randomNeighbour = elem(state.neighbours, :rand.uniform(numNeighbours)-1)
#         IO.write "Sending rumour to"; IO.inspect randomNeighbour
#         receiveRumour(randomNeighbour, state.rumour.text)
#       true -> IO.puts("finish")
#         #Terminate program
#     end
#   end

#   def handle_call(arg1, _from, state) do
#     {method, methodArgs} = arg1
#     case method do
#       :learnNeighbours -> 
#         {neighbours} = methodArgs
#         {:reply, :ok, put_in state.neighbours, neighbours}
#       :inspect -> 
#         {:reply, state, state}
#       :receiveRumour ->
#         {rumour} = methodArgs
#         newState = handleReceiveRumour(rumour, state)
#         sendRumour(_from, rumour)
#         {:reply, :ok, newState}
#       :sendRumour ->
#         {rumour} = methodArgs
#         newState = handleSendRumour(state)
#         {:reply, :ok, state}
#     end
#   end

# end