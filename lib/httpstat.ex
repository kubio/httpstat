defmodule Httpstat do

    import Formatter
    import Parser

    def main(args) do
        url = hd(args)

        cond do
            url == "-h"                         -> help
            url == "--help"                     -> help
            url == "--version"                  -> version
            String.match?(url, ~r/https?:\/\//) -> exec(args)
            true                                -> help
        end

    end

    def exec(args) do
        # check curl args
        [url|options] = args

        exclude_args = [
            "-w", "--write-out", "-D", "--dump-header",
            "-o", "--output", "-s", "--silent"
        ]

        {:ok, bfd, head_file_path} = Temp.open "httpstat-head"
        {:ok, hfd, body_file_path} = Temp.open "httpstat-body"
        # IO.puts head_file_path
        # IO.puts body_file_path
        File.close bfd
        File.close hfd

        # run curl
        default_args = [
            "-w", status_format, "-D", head_file_path, "-o", body_file_path, "-s", "-S"
        ]
        options = options -- exclude_args
        {response, 0} = System.cmd("curl", default_args ++ [url])

        # parse result
        times = Poison.Parser.parse!(response)
        base = template( String.match?(url, ~r/https:\/\//) )
        base = parse(times, base)

        # -------- output
        # header
        {:ok, header} = File.read head_file_path

        lines = String.trim(header)
            |> String.split("\n")
        Enum.map_reduce( lines, 0, fn (line, acc) ->
            if acc === 0 do
                [first, second] = String.split(line, "/", parts: 2)
                IO.puts [color_green(first), "/", color_cyan(second)]
            else
                [first, second] = String.split(line, ":", parts: 2)
                IO.puts [color_gray(first), ":", color_cyan(second)]
            end
            {line, acc+1}
        end)
        IO.puts ""

        # body
        if Enum.find_value( options, fn(option) -> option == "--show-body" end) do
            {:ok, body} = File.read body_file_path
            IO.puts ""
            IO.puts body
        end

        IO.puts [color_green("body"), " stored in: #{body_file_path}"]

        # status
        IO.puts ""
        IO.puts base

        # speed
        # speed_dl = fmt_b2kb(times["speed_download"])
        # speed_ul = fmt_b2kb(times["speed_upload"])
        # IO.puts ""
        # IO.puts ["speed download: ", IO.ANSI.cyan, "#{speed_dl}Kib", IO.ANSI.reset, "/s"]
        # IO.puts ["speed upload: ", IO.ANSI.cyan, "#{speed_ul}Kib", IO.ANSI.reset, "/s"]

        File.rm head_file_path

    end

end
