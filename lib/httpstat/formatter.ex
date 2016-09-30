defmodule Formatter do

    def color_green(text) do
        Enum.join([IO.ANSI.green, "#{text}", IO.ANSI.reset])
    end
    def color_cyan(text) do
        Enum.join([IO.ANSI.cyan, "#{text}", IO.ANSI.reset])
    end
    def color_gray(text) do
        Enum.join([Bunt.ANSI.dimgray, "#{text}", IO.ANSI.reset])
    end

    def fmt_b2kb(b) do
        Float.round(b/1024, 3)
    end

    def fmt_s2ms(s) do
        Float.round(s, 3)*1000
        |> round
        |> Integer.to_string
        |> String.rjust(5)
    end

    def version do
        IO.puts "httpstat "<>Application.get_env(:httpstat, :version)
    end

    def help do
        IO.puts """

        Usage: httpstat URL [CURL_OPTIONS]
               httpstat -h | --help
               httpstat --version
        Arguments:
          URL     url to request, could be with or without `http(s)://` prefix
        Options:
          CURL_OPTIONS  any curl supported options, except for -w -D -o -S -s,
                        which are already used internally.
          -h --help     show this screen.
          --version     show version.
        Environments:
          HTTPSTAT_SHOW_BODY    By default httpstat will write response body
                                in a tempfile, but you can let it print out by setting
                                this variable to `true`.
          HTTPSTAT_SHOW_SPEED   set to `true` to show download and upload speed.
        """
    end

    def template(is_ssl) do
        if is_ssl do
"""
  DNS Lookup   TCP Connection   SSL Handshake   Server Processing   Content Transfer
[   {a0000}  |     {a0001}    |    {a0002}    |      {a0003}      |      {a0004}     ]
             |                |               |                   |                  |
    namelookup:{b0000}        |               |                   |                  |
                        connect:{b0001}       |                   |                  |
                                    pretransfer:{b0002}           |                  |
                                                      starttransfer:{b0003}          |
                                                                                 total:{b0004}
"""
        else
"""
  DNS Lookup   TCP Connection   Server Processing   Content Transfer
[   {a0000}  |     {a0001}    |      {a0003}      |      {a0004}     ]
             |                |                   |                  |
    namelookup:{b0000}        |                   |                  |
                        connect:{b0001}           |                  |
                                      starttransfer:{b0003}          |
                                                                 total:{b0004}
"""
        end
    end

    def status_format() do
        """
{
    "time_namelookup": %{time_namelookup},
    "time_connect": %{time_connect},
    "time_appconnect": %{time_appconnect},
    "time_pretransfer": %{time_pretransfer},
    "time_redirect": %{time_redirect},
    "time_starttransfer": %{time_starttransfer},
    "time_total": %{time_total},
    "speed_download": %{speed_download},
    "speed_upload": %{speed_upload}
}
"""
    end
end
