require 'rubygems'
require 'addressable/uri'
require 'net/http'
require 'uri'

module Ikran
  class Reader
    attr_accessor :verbose

    COMMANDS = ["exit", "server", "ping", "head", "verbose", "truncate"]
    STATUS_REGEXP = /#<Net::HTTP[a-zA-Z]+ (.+) readbody=(?:true|false)>/

    def parse(command)
      cmd = command.split(' ')
      if COMMANDS.include? cmd.first
        cmd.length > 1 ? ("#{cmd[0]} '#{cmd[1]}'") : cmd.first
      end
    end

    def exit
      @running = false
      "exiting ..."
    end

    def server(val = nil)
      if val
        begin
          @server = Addressable::URI.heuristic_parse(val).to_s
          "remote set to #{@server}"
        rescue Addressable::URI::InvalidURIError => e
          "invalid url"
        end
      else
        @server ? "current remote is #{@server}" : "remote is not set"
      end
    end

    def ping
      if not @server
        "remote must be set before executing ping without parameters"
      elsif http_ping(@server)
        "#{@server} is alive"
      else
        "#{@server} is unreachable"
      end
    end

    def http_ping(url)
      get_url(url).to_i < 400
    end

    def get_url(url)
      Net::HTTP.get_response(URI.parse(url)).inspect =~ STATUS_REGEXP
    end

    def head
      return "remote must be set before executing head" unless @server
      res = Net::HTTP.get_response(URI.parse(@server))
      if res.inspect =~ STATUS_REGEXP
        if @verbose
          (@size.to_i > 0) ? res.body[0, @size] : res.body
        else
          $1
        end
      else
        "invalid response #{res.inspect}"
      end
    end

    def verbose
      # TODO - add option to truncate output to max number of characters
      "verbose is now " + ((@verbose = !@verbose) ? "ON" : "OFF")
    end

    def truncate(size = nil)
      if size
        @size = (size.to_i == 0 ? nil : size.to_i)
        @size ? "maximum size set to #{@size}" : "maximum size set to infinite"
      else
        @size ? "maximum size is #{@size}" : "maximum size is infinite" 
      end
    end

    def exec(command)
      cmd = parse(command)
      if cmd
        instance_eval(cmd)
      else
        "command #{command} doesn't exist"
      end
    end

    def run
      @running = true
      while @running
        print ">> "
        line = gets.chomp!
        puts exec(line)
      end
    end

    def self.aliases(opts)
      opts.each do |original, aliased|
        [*aliased].each do |a|
          alias_method a, original
          COMMANDS << a.to_s
        end
      end
    end

    aliases :server => [:s, :r, :remote], :head => :h, :ping => :p, :verbose => :v, :exit => :e,
            :truncate => :t
  end
end