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

    COMMANDS = ["exit", "server", "ping", "head"]


    def parse(command)
      cmd = command.split(' ')
      if COMMANDS.include? cmd.first
        cmd.length > 1 ? ("#{cmd[0]} '#{cmd[1]}'") : cmd.first
      end
    end

    def exit
      "exitting ..."
    end

    def server(val = nil)
      if val
        begin
          @server = Addressable::URI.heuristic_parse(val)
          "remote set to #{remote}"
        rescue Addressable::URI::InvalidURIError => e
          "invalid url"
        end
      else
        "current remote is #{remote}"
      end
    end

    def ping
      if not @server
        "remote must be set before executing ping without parameters"
      elsif Ping.pingecho(@server)
        "#{remote} is alive"
      else
        "#{remote} is unreachable"
      end
    end

    def head
      return "remote must be set before executing get" unless @server
      res = Net::HTTP.get_response(URI.parse(remote))
      if res.inspect =~ /#<Net::HTTP[a-zA-Z]+ (.+) readbody=(?:true|false)>/
        $1
      else
        "invalid response #{res.inspect}"
      end
    end

    def exec(command)
      cmd = parse(command)
      if cmd
        instance_eval(cmd)
      else
        "command doesn't exist"
      end
    end
  end

end