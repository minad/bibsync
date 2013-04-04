module BibSync
  module Actions
    class SynchronizeFiles
      include Utils
      include Log

      FileTypes = %w(djvu pdf ps)

      def initialize(options)
        raise 'Bibliography must be set' unless @bib = options[:bib]
        raise 'Directory must be set' unless @dir = options[:dir]
      end

      def run
        notice 'Synchronize with files'

        files = {}
        Dir[File.join(@dir, "**/*.{#{FileTypes.join(',')}}")].sort.each do |file|
          name = File.basename(file)
          key, type = split_filename(name)
          raise "Duplicate file #{name}" if files[key]
          files[key] = file
        end

        files.each do |key, file|
          unless entry = @bib[key]
            info('New file', :key => key)
            entry = Bibliography::Entry.new
            entry.key = key
            @bib << entry
          end

          entry.type ||= :ARTICLE
          entry.file = file
        end

        @bib.save
      end
    end
  end
end
