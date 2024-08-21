defmodule Mix.Tasks.Docify do
  @moduledoc false
  @shortdoc "Output text file showing replacement characters for transliteration"
  use Mix.Task

  def run(_args) do
    data = read_from_priv!("data.json")

    replacements =
      for i <- 0..255,
          characters = Map.get(data, Integer.to_string(i)),
          is_list(characters),
          {character, index} <- Enum.with_index(characters),
          into: %{} do
        codepoint = i * 256 + index
        {List.to_string([codepoint]), character}
      end

    write_to_priv!(replacements, "transliterations.txt")
  end

  defp read_from_priv!(filename) do
    :code.priv_dir(:slugify)
    |> Path.join(filename)
    |> File.read!()
    |> Jason.decode!()
  end

  defp write_to_priv!(replacements, filename) do
    path = Path.join(:code.priv_dir(:slugify), filename)

    data =
      Enum.reduce(replacements, "", fn {original, translated}, acc ->
        if not whitespace_only?(translated) do
          acc <> "#{original} : #{translated}\n"
        else
          acc
        end
      end)

    File.write!(path, data)
  end

  defp whitespace_only?(nil), do: true
  defp whitespace_only?(string), do: String.trim(string) == ""
    
end
