module BibSync
  class JabRefFormatter
    include Log

    def call(file)
      if File.read(file, 80) !~ /JabRef/
        notice 'Transforming file with JabRef'
        tmp_file = "#{file}.formatted.bib"
        begin
          `jabref --primp #{Shellwords.escape File.join(File.dirname(__FILE__), 'jabref.xml')} --nogui --import #{Shellwords.escape file} --output #{Shellwords.escape tmp_file} 2>&1 >/dev/null`
          File.rename(tmp_file, file) if File.exists?(tmp_file)
        ensure
          File.unlink(tmp_file) rescue nil
        end
      end
    end
  end
end
