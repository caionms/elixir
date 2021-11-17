defmodule Todo do
  @moduledoc """
  É executado uma aplicacao de TODO's. Sendo feita operacoes de
  mostrar seus afazeres, deletar e executar saida a partir de um
  documento .csv
  """

  @doc """
  Funcao inicial que pede ao usuario para informar o nome do documento
  a ser feito as operacoes
  """

  def start do
    filename = IO.gets("Digite o nome do .csv para ser utilizado: ") |> String.trim()
    read(filename)
      |> parse
      |> get_command

  end

  @doc """
  Funcao que mostra as opcoes de operacao ao usuario e executa tal operacao
  """
  def get_command(data) do
    prompt = """
      Digite a primeira letra do comando para executar\n
      L)er Todos  A)dicionar um Todo  D)eletar um Todo  C)arregar um .csv  S)alvar um .csv
    """

    command = IO.gets(prompt)
      |> String.trim
      |> String.downcase

    case command do
      "l" -> show_todos(data)
      "d" -> delete_todo(data)
      "q" -> "Goodbye!"
      _ -> get_command(data)
    end
  end

   @doc """
  Funcao que deleta uma linha do .csv, ou seja, um TODO
  """
  def delete_todo(data) do
    todo = IO.gets("Qual todo voce gostaria de excluir?\n") |> String.trim
    if Map.has_key?(data, todo) do
      IO.puts("OK.")
      new_map = Map.drop(data, [todo])
      IO.puts(~s{"#{todo}" foi deletado.})
      get_command(new_map)
    else
      IO.puts(~s(Não existe nenhum todo chamado "#{todo}"!))
      show_todos(data, false)
      delete_todo(data)
    end
  end

  @doc """
  Funcao que ler o arquivo .csv
  """

  def read(filename) do
    case File.read(filename) do
      {:ok, body} ->
        body

      {:error, reason} ->
        IO.puts(~s(Não foi possivel abrir o arquivo "#{filename}"\n))
        IO.puts(~s("#{:file.format_error(reason)}"\n))
        start()
    end
  end


  @doc """
  Funcao que auxilia na leitura dos arquivos
  """
  def parse(body) do
    [header | lines] = String.split(body, ~r{(\r\n|\r|\n)})
    titles = tl(String.split(header, ","))
    parse_lines(lines, titles)
  end

  @doc """
  Funcao que auxilia na leitura dos arquivos
  """
  def parse_lines(lines, titles) do
    Enum.reduce(lines, %{}, fn line, built ->
      [name | fields] = String.split(line, ",")
      if Enum.count(fields) == Enum.count(titles) do
        line_data = Enum.zip(titles, fields) |> Enum.into(%{})
        Map.merge(built, %{name => line_data})
      else
        built
      end
    end)
  end

  @doc """
  Funcao que mostra os TODO's do arquivo
  """
  def show_todos(data, next_command? \\ true) do
    items = Map.keys(data)
    IO.puts("Voce possui o(s) seguinte(s) Todos:\n")
    Enum.each(items, fn item -> IO.puts(item) end)
    IO.puts("\n")
    if next_command? do
      get_command(data)
    end
  end
end

# c "todo.ex"
# Todo.start
