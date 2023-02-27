defmodule Issues.CLI do
  @default_count 4
  @moduledoc """
  명령줄 파싱 후, 함수 호출
  깃허브 프로젝트의 최근 n개의 이슈 표로 출력
  """

  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  'argv'는 -h, --help 이거나 깃허브 사용자 이름, 프로젝트 이름, 이슈 개수여야한다.
  '{사용자명, 프로젝트명, 이슈 개수}' 또는 :help 반환
  """

  def parse_args(argv) do
    OptionParser.parse(argv, switches: [help: :boolean], aliases: [h: :help])
    |> elem(1)
    |> args_to_internal_representation()
  end

  def args_to_internal_representation([user, project, count]) do
    {user, project, String.to_integer(count)}
  end

  def args_to_internal_representation([user, project]) do
    {user, project, @default_count}
  end

  def args_to_internal_representation(_) do
    :help
  end

  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [count | #{@default_count}]
    """

    System.halt(0)
  end

  def process({user, project, _count}) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_reponse()
  end

  def decode_response({:ok, body}), do: body

  def decode_response({:error, error}) do
    IO.puts "Error fetching from Github: #{error["message"]}"
    System.halt(2)
  end

end
