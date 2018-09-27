defmodule Participant do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{
      :neighbours => {},
      :rumour => %{
        :text => nil,
        :count => 0
      }
    } end)
    #Send pid to GenServer
  end

  def learnNeighbours(participant, neighbours) do
    # IO.write("learnNeighbours "); IO.inspect(participant); IO.inspect(neighbours)
    Agent.update(participant, fn state -> 
      put_in state.neighbours, neighbours
    end)
  end

  # def inspect(participant) do 
  #   Agent.get(participant, fn state -> IO.inspect state end)
  # end

  def receiveRumour(participant, rumour) do
    IO.write "Rumour received by "; IO.inspect participant    
    Agent.update(participant, fn state ->
     cond do
       state.rumour.text == rumour -> put_in state.rumour.count, state.rumour.count + 1
       state.rumour.text == nil -> put_in state.rumour, %{:text => rumour, :count => 1} 
       true -> raise "Invalid rumour"
     end
    end)
    sendRumour(participant)
  end

  def sendRumour(participant) do
    Agent.get(participant, fn state ->
      cond do
        state.rumour.count < 10 ->
          numNeighbours = tuple_size state.neighbours
          if(numNeighbours == 0) do raise "No neighbours" end
          randomNeighbour = elem(state.neighbours, :rand.uniform(numNeighbours)-1)
          IO.write "Sending rumour to"; IO.inspect randomNeighbour
          receiveRumour(randomNeighbour, state.rumour.text)
        true -> IO.puts("finish")
          #Terminate program
      end
    end)
  end
end