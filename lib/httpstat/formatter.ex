defmodule Formatter do

    def make_color() do

    end

    def fmt_mb2kb(mb) do
        Float.round(mb/1024, 3)
    end

    def version do
        IO.puts "httpstat "<>Application.get_env(:httpstat, :version)
        IO.puts "https://github.com/kubio/httpstat"
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
