module BibSync
  module Log
    Reset = "\e[0m"
    Red = "\e[31m"
    Yellow = "\e[33m"
    Blue = "\e[36m"

    Level = {
      debug:   nil,
      info:    nil,
      notice:  Blue,
      warning: Yellow,
      error:   Red,
    }

    class << self
      attr_accessor :level, :trace
    end

    self.trace = false
    self.level = :info

    [:debug, :info, :notice, :warning, :error].each do |level|
      define_method level do |message, opts = {}|
        log(level, message, opts)
      end
    end

    def log(level, message, opts = {})
      return if Level.keys.index(level) < Level.keys.index(Log.level)
      message = "#{message} - #{opts[:ex].message}" if opts[:ex]
      message = "#{Level[level]}#{message}#{Reset}" if Level[level]
      if key = opts[:key]
        key = key.key if key.respond_to? :key
        message = "#{key} : #{message}"
      end
      puts(message)
      if Log.trace && ex = opts[:ex]
        puts(ex.backtrace.join("\n"))
      end
    end
  end
end
