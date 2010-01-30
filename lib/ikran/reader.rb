require 'ping'
require 'addressable/uri'

module Ikran
  class Reader
    attr_accessor :server

    def exec(command)
      case command
        when "exit"
          "exitting ..."
        when "server"
          "current remote is #{@server}"
        when /server (.+)/
          begin
            @server = Addressable::URI.heuristic_parse($1).host
            "remote set to #{@server}"
          rescue Addressable::URI::InvalidURIError => e
            "invalid url"
          end
        when "ping"
          if not @server
            "remote must be set before executing ping without parameters"
          elsif Ping.pingecho(@server)
            "#{@server} is alive"
          else
            "#{@server} is unreachable"
          end
        else
          "command doesn't exist"
      end
    end
  end

end