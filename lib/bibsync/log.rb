module BibSync
  module Log
    Reset = "\e[0m"
    Red = "\e[31m"
    Yellow = "\e[33m"
    Blue = "\e[36m"

    def self.verbose?
      @verbose
    end

    def self.verbose!
      @verbose = true
    end

    def self.trace?
      @trace
    end

    def self.trace!
      @trace = true
    end

    def debug(message, opts = {})
      info(message, opts) if Log.verbose?
    end

    def info(message, opts = {})
      log(message, opts)
    end

    def notice(message, opts = {})
      log(message, opts.merge(color: Blue))
    end

    def warning(message, opts = {})
      log(message, opts.merge(color: Yellow))
    end

    def error(message, opts = {})
      log(message, opts.merge(color: Red))
    end

    def log(message, opts = {})
      if ex = opts[:ex]
        message = "#{message} - #{ex.message}"
      end
      message = "#{opts[:color]}#{message}#{Reset}" if opts[:color]
      if key = opts[:key]
        key = key.key if key.respond_to? :key
        message = "#{key} : #{message}"
      end
      puts(message)
      if Log.trace? && ex = opts[:ex]
        puts(ex.backtrace.join("\n"))
      end
    end
  end
end
