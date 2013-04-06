module BibSync
  module Actions
    class Validate
      include Utils
      include Log

      def initialize(options)
        raise 'Bibliography must be set' unless @bib = options[:bib]
      end

      def run
        notice 'Check validity'
        titles, arxivs, dois = {}, {}, {}

        @bib.each do |entry|
          next if entry.comment?

          w = []

          file = entry.file

          missing = []
          missing << :file unless file && File.file?(file[:path])
          missing += [:title, :author, :year, :abstract].reject {|k| entry[k] }
          w << "Missing #{missing.map(&:to_s).sort.join(', ')}" unless missing.empty?

          w << 'File name does not match entry key' if split_filename(file[:name]).first != entry.key if file

          if entry[:arxiv]
            id = arxiv_id(entry, :version => false, :prefix => true)
            if arxivs.include?(id)
              w << "ArXiv duplicate of '#{arxivs[id]}'"
            else
              arxivs[id] = entry.key
            end
          end

          if id = entry[:doi]
            if dois.include?(id)
              w << "DOI duplicate of '#{dois[id]}'"
            else
              dois[id] = entry.key
            end
          end

          if entry[:title]
            if titles.include?(entry[:title])
              w << "Title duplicate of '#{titles[entry[:title]]}'"
            else
              titles[entry[:title]] = entry.key
            end
          end

          warning(w.join('; '), :key => entry) unless w.empty?
        end
      end
    end
  end
end
