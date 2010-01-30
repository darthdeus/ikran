require 'rubygems'
require 'ping'
require 'addressable/uri'
require 'open-uri'
require 'uri'

module Ikran
  class Reader
    attr_accessor :server, :verbose

    def remote
      @server
    end

    COMMANDS = ["exit", "server", "ping", "head", "verbose"]


    def parse(command)
      cmd = command.split(' ')
      if COMMANDS.include? cmd.first
        cmd.length > 1 ? ("#{cmd[0]} '#{cmd[1]}'") : cmd.first
      end
    end

    def exit
      @running = false
      "exitting ..."
    end

    def server(val = nil)
      if val
        begin
          @server = Addressable::URI.heuristic_parse(val).to_s
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
      elsif Ping.pingecho(URI.parse(@server))
        "#{remote} is alive"
      else
        "#{remote} is unreachable"
      end
    end

    def head
      return "remote must be set before executing get" unless @server

      open(remote) do |f|
        if @verbose
          f.meta.map { |k, v| "#{k}: #{v}"}
        else
          f.status.join " "
        end
      end
    end

    def verbose
      "verbose is now " + (@verbose = !@verbose ? "ON" : "OFF") 

    end

    def exec(command)
      cmd = parse(command)
      if cmd
        instance_eval(cmd)
      else
        "command doesn't exist"
      end
    end

    def run
      @running = true
      while @running
        line = gets.chomp!
        puts exec(line)
      end
    end
  end

end