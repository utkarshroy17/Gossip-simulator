defmodule MyList do
  def delete_all(list, el) do
    _delete_all(list, el, []) |> Enum.reverse()
  end

  def _delete_all([head | tail], el, new_list) when head === el do
    _delete_all(tail, el, new_list)
  end

  def _delete_all([head | tail], el, new_list) do
    _delete_all(tail, el, [head | new_list])
  end

  def _delete_all([], el, new_list) do
    new_list
  end
end

defmodule RC do
  def nth_root(n, x, precision \\ 1.0e-5) do
    f = fn prev -> ((n - 1) * prev + x / :math.pow(prev, n - 1)) / n end
    fixed_point(f, x, precision, f.(x))
  end

  defp fixed_point(_, guess, tolerance, next) when abs(guess - next) < tolerance, do: next
  defp fixed_point(f, _, tolerance, next), do: fixed_point(f, next, tolerance, f.(next))
end

defmodule Gen_rand do
  def rand_elem(y, x) do
    rand = Enum.random(0..(x - 1))

    cond do
      rand == y || rand == y + 1 || rand == y - 1 -> rand_elem(y, x)
      true -> rand
    end
  end
end
