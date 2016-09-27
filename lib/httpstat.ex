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
        is_ssl_connect = false
        if String.match?(url, ~r/https:\/\//) do
            is_ssl_connect = true
        end
        base = template( is_ssl_connect )
        base = parse(times, base)

        # -------- output
        # header
        {:ok, header} = File.read head_file_path
        IO.puts header

        # body
        if Enum.find_value( options, fn(option) -> option == "--show-body" end) do
            {:ok, body} = File.read body_file_path
            IO.puts ""
            IO.puts body
        end

        # status
        IO.puts ""
        IO.puts base

        # speed
        speed_dl = fmt_b2kb(times["speed_download"])
        speed_ul = fmt_b2kb(times["speed_upload"])
        IO.puts ""
        IO.puts "speed download: #{speed_dl}Kib"
        IO.puts "speed upload: #{speed_ul}Kib"

        File.rm head_file_path
        File.rm body_file_path

    end

end
