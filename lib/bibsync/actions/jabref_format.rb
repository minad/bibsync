module BibSync
  module Actions
    class JabrefFormat
      include Utils
      include Log

      def initialize(options)
        raise 'Bibliography must be set' unless @bib = options[:bib]
      end

      def run
        @bib.save
        if File.read(@bib.file, 80) !~ /JabRef/
          notice 'Transforming file with JabRef'
          tmp_file = "#{@bib.file}.tmp.bib"
          `jabref --nogui --import #{Shellwords.escape @bib.file} --output #{Shellwords.escape tmp_file} 2>&1 >/dev/null`
          File.rename(tmp_file, @bib.file) if File.exists?(tmp_file)
        end
      end
    end
  end
end
