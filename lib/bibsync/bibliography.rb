module BibSync
  class Bibliography
    include Enumerable

    attr_reader :file

    def initialize(file = nil)
      @entries, @file = {}, file
      parse(File.read(@file)) if @file && File.exists?(@file)
      @dirty = false
      @save_hooks = []
    end

    def save_hook(hook)
      @save_hooks << hook
    end

    def dirty?
      @dirty
    end

    def dirty!
      @dirty = true
    end

    def [](key)
      @entries[key]
    end

    def delete(entry)
      if @entries.include?(entry.key)
        @entries.delete(entry.key)
        entry.bibliography = nil
        dirty!
      end
    end

    def relative_path(file)
      raise 'No filename given' unless @file
      bibpath = Pathname.new(@file).realpath.parent
      Pathname.new(file).realpath.relative_path_from(bibpath).to_s
    end

    def each(&block)
      @entries.each_value(&block)
    end

    def save(file = nil)
      if file
        @file = file
        @parent_path = nil
        @dirty = true
      end

      raise 'No filename given' unless @file
      if @dirty
        @save_hooks.each {|hook| hook.call(self) }
        File.open("#{@file}.tmp", 'w') {|f| f.write(self) }
        File.rename("#{@file}.tmp", @file)
        @dirty = false
        true
      else
        false
      end
    end

    def <<(entry)
      entry.bibliography = self
      @entries[entry.key] = entry
      dirty!
    end

    def parse(text)
      until text.empty?
        case text
        when /\A(\s+|%[^\n]+\n)/
          text = $'
        else
          entry = Entry.new
          text = entry.parse(text)
          entry.key ||= @entries.size
          self << entry
        end
      end
    end

    def to_s
      "% #{DateTime.now}\n% Encoding: UTF8\n\n" <<
        @entries.values.join("\n") << "\n"
    end

    class RawValue < String; end

    class Entry
      include Enumerable

      attr_accessor :key, :type, :bibliography

      def self.parse(text)
        entry = Entry.new
        entry.parse(text)
        entry
      end

      def initialize
        @fields = {}
      end

      def file=(file)
        raise 'No bibliography set' unless bibliography
        file =~ /\.(\w+)$/
        self[:file] = ":#{bibliography.relative_path(file)}:#{$1.upcase}" # JabRef file format "description:path:type"
        file
      end

      def file
        if self[:file]
          raise 'No bibliography set' unless bibliography
          description, file, type = self[:file].split(':', 3)
          path = (Pathname.new(bibliography.file).realpath.parent + file).to_s
          { :name => File.basename(path), :type => type.upcase.to_sym, :path => path }
        end
      end

      def [](key)
        @fields[convert_key(key)]
      end

      def []=(key, value)
        if value then
          key = convert_key(key)
          value = RawValue === value ? RawValue.new(value.to_s.strip) : value.to_s.strip
          if @fields[key] != value || @fields[key].class != value.class
            @fields[key] = value
            dirty!
          end
        else
          delete(key)
        end
      end

      def delete(key)
        key = convert_key(key)
        if @fields.include?(key)
          @fields.delete(key)
          dirty!
        end
      end

      def each(&block)
        @fields.each(&block)
      end

      def comment?
        type.to_s.downcase == 'comment'
      end

      def dirty!
        bibliography.dirty! if bibliography
      end

      def to_s
        s = "@#{type}{"
        if comment?
          s << self[:comment]
        else
          s << "#{key},\n" << to_a.map {|k,v| RawValue === v ? "  #{k} = #{v}" : "  #{k} = {#{v}}" }.join(",\n") << "\n"
        end
        s << "}\n"
      end

      def parse(text)
        raise 'Unexpected token' if text !~ /\A\s*@(\w+)\s*\{/
        self.type = $1
        text = $'

        if comment?
          text, self[:comment] = parse_field(text)
        else
          raise 'Expected entry key' if text !~ /([^,]+),\s*/
          self.key = $1.strip
          text = $'

          until text.empty?
            case text
            when /\A(\s+|%[^\n]+\n)/
              text = $'
            when /\A\s*(\w+)\s*=\s*/
              text, key = $', $1
              if text =~ /\A\{/
                text, self[key] = parse_field(text)
              else
                text, value = parse_field(text)
                self[key] = RawValue.new(value)
              end
            else
              break
            end
          end
        end

        raise 'Expected closing }' unless text =~ /\A\s*\}/
        $'
      end

      private

      def parse_field(text)
        value = ''
        count = 0
        until text.empty?
          case text
          when /\A\{/
            text = $'
            value << $& if count > 0
            count += 1
          when /\A\}/
            break if count == 0
            count -= 1
            text = $'
            value << $& if count > 0
          when /\A,/
            text = $'
            break if count == 0
            value << $&
          when /\A[^\}\{,]+/
            text = $'
            value << $&
          else
            break
          end
        end

        raise 'Expected closing }' if count != 0

        return text, value
      end

      def convert_key(key)
        key.to_s.downcase.to_sym
      end
    end
  end
end
