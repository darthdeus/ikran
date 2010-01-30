require 'ping'
require 'addressable/uri'
require 'net/http'
require 'uri'

module Ikran
  class Reader
    attr_accessor :server

    def remote
      @server.to_s
    end

    def exec(command)
      case command
        when "exit"
          "exitting ..."
        when "server"
          "current remote is #{remote}"
        when /server (.+)/
          begin
            @server = Addressable::URI.heuristic_parse($1)
            "remote set to #{remote}"
          rescue Addressable::URI::InvalidURIError => e
            "invalid url"
          end
        when "ping"
          if not @server
            "remote must be set before executing ping without parameters"
          elsif Ping.pingecho(@server)
            "#{remote} is alive"
          else
            "#{remote} is unreachable"
          end
        when "head"
          return "remote must be set before executing get" unless @server
          res = Net::HTTP.get_response(URI.parse(remote))
          if res.inspect =~ /#<Net::HTTP[a-zA-Z]+ (.+) readbody=(?:true|false)>/
            $1
          else
            "invalid response #{res.inspect}"
          end
        else
          "command doesn't exist"
      end
    end
  end

end