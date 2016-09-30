defmodule Parser do



    def parse(times, base_template) do

        range_dns = times["time_namelookup"]
        range_connection = times["time_connect"] - times["time_namelookup"]
        range_ssl = times["time_pretransfer"] - times["time_connect"]
        range_server = times["time_starttransfer"] - times["time_pretransfer"]
        range_transfer = times["time_total"] - times["time_starttransfer"]

        base_template = String.replace(base_template, ~r/{a0000}/, Formatter.color_cyan "#{Formatter.fmt_s2ms(range_dns)}ms")
        base_template = String.replace(base_template, ~r/{a0001}/, Formatter.color_cyan "#{Formatter.fmt_s2ms(range_connection)}ms")
        base_template = String.replace(base_template, ~r/{a0002}/, Formatter.color_cyan "#{Formatter.fmt_s2ms(range_ssl)}ms")
        base_template = String.replace(base_template, ~r/{a0003}/, Formatter.color_cyan "#{Formatter.fmt_s2ms(range_server)}ms")
        base_template = String.replace(base_template, ~r/{a0004}/, Formatter.color_cyan "#{Formatter.fmt_s2ms(range_transfer)}ms")

        base_template = String.replace(base_template, ~r/{b0000}/, Formatter.color_cyan "#{Formatter.fmt_s2ms(times["time_namelookup"])}ms")
        base_template = String.replace(base_template, ~r/{b0001}/, Formatter.color_cyan "#{Formatter.fmt_s2ms(times["time_connect"])}ms")
        base_template = String.replace(base_template, ~r/{b0002}/, Formatter.color_cyan "#{Formatter.fmt_s2ms(times["time_pretransfer"])}ms")
        base_template = String.replace(base_template, ~r/{b0003}/, Formatter.color_cyan "#{Formatter.fmt_s2ms(times["time_starttransfer"])}ms")
        base_template = String.replace(base_template, ~r/{b0004}/, Formatter.color_cyan "#{Formatter.fmt_s2ms(times["time_total"])}ms")

        base_template
    end
end
