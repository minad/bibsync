module BibSync
  module Actions
    class SynchronizeFiles
      include Utils
      include Log

      FileTypes = %w(djvu pdf ps)

      def initialize(options)
        raise 'Option --bib is required' unless @bib = options[:bib]
        raise 'Option --dir is required' unless @dir = options[:dir]
        @dir = File.join(@dir, '**') unless options[:non_recursive]
      end

      def run
        notice 'Synchronize with files'

        files = {}
        Dir[File.join(@dir, "*.{#{FileTypes.join(',')}}")].sort.each do |file|
          name = File.basename(file)
          if name =~ /\A[\w\.\-]+\Z/
            key = name_without_ext(name)
            raise "Duplicate file #{name}" if files[key]
            files[key] = file
          else
            warning('File with invalid name', key: name)
          end
        end

        files.each do |key, file|
          unless entry = @bib[key]
            info('New file', key: key)
            entry = Entry.new(key: key)
            @bib << entry
          end

          entry.type ||= :ARTICLE
          entry.file = file
        end
      end
    end
  end
end
