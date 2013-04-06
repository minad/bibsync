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

    def debug(message, opts = {})
      log(:debug, message, opts)
    end

    def info(message, opts = {})
      log(:info, message, opts)
    end

    def notice(message, opts = {})
      log(:notice, message, opts)
    end

    def warning(message, opts = {})
      log(:warning, message, opts)
    end

    def error(message, opts = {})
      log(:error, message, opts)
    end

    def log(level, message, opts = {})
      return if Level.keys.index(level) < Level.keys.index(Log.level)
      if ex = opts[:ex]
        message = "#{message} - #{ex.message}"
      end
      if color = Level[level]
        message = "#{color}#{message}#{Reset}"
      end
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
