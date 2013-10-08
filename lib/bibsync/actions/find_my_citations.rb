module BibSync
  module Actions
    class FindMyCitations
      include Log
      include Utils

      def initialize(options)
        raise 'Option --bib is required' unless @bib = options[:bib]
        raise 'Option --citedbyme is required' unless @dir = options[:citedbyme]
        raise "#{@dir} is not a directory" unless File.directory?(@dir)
      end

      def run
        notice 'Find citations in my TeX files'

        cites = {}
        Dir[File.join(@dir, '**/*.tex')].each do |file|
          File.read(file).scan(/cite\{([^\}]+)\}/) do
            $1.split(/\s*,\s*/).each do |key|
              key.strip!
              file = @bib.relative_path(file)
              debug("Cited in #{file}", key: key)
              (cites[key] ||= []) << file
            end
          end
        end

        @bib.each do |entry|
          next if entry.comment?
          entry.delete(:cites) unless cites.include?(entry.key)
        end

        cites.each do |key, files|
          files = files.sort.uniq.join(';')
          if @bib[key]
            @bib[key][:citedbyme] = files
          else
            warning("Cited in #{files} but not found in #{@bib.file}", key: key)
          end
        end
      end
    end
  end
end
