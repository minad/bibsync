module BibSync
  module Actions
    class DetermineArXivDOI
      include Utils
      include Log

      def initialize(options)
        raise 'Option --bib is required' unless @bib = options[:bib]
        @force = options[:resync]
      end

      def run
        notice 'Determine arXiv and DOI identifiers'

        @bib.each do |entry|
          next if entry.comment? ||
                  (entry[:doi] && entry[:arxiv]) ||
                  (!@force && entry[:title] && entry[:author] && entry[:year])

          determine_arxiv_and_doi(entry)
        end
      end

      private

      def determine_arxiv_and_doi(entry)
        if file = entry.file
          if file[:type] == 'PDF' && !entry[:arxiv] && !entry[:doi]
            debug('Searching for arXiv or doi identifier in pdf file', key: entry)
            text = `pdftotext -f 1 -l 2 #{Shellwords.escape file[:path]} - 2>/dev/null`
            entry[:arxiv] = $1 if text =~ /arXiv:\s*([\w\.\/\-]+)/
            entry[:doi] = $1 if text =~ /doi:\s*([\w\.\/\-]+)/i
          end

          if !entry[:arxiv] && file[:name] =~ /^(\d+.\d+v\d+)\.\w+$/
            debug('Interpreting file name as arXiv identifier', key: entry)
            entry[:arxiv] = $1
          end

          if !entry[:doi] && file[:name] =~ /^(PhysRev.*?|RevModPhys.*?)\.\w+$/
            debug('Interpreting file name as doi identifier', key: entry)
            entry[:doi] = "10.1103/#{$1}"
          end
        end

        if !entry[:arxiv] && entry[:doi]
          begin
            info('Fetch missing arXiv identifier', key: entry)
            xml = fetch_xml('http://export.arxiv.org/api/query', search_query: "doi:#{entry[:doi]}", max_results: 1)
            doi = xml.elements['//arxiv:doi']
            if doi && doi.text == entry[:doi]
              id = xml.elements['//entry/id'].text
              if id =~ %r{\Ahttp://arxiv.org/abs/(.+)\Z}
                entry[:arxiv] = $1
              end
            end
          rescue => ex
            error('arXiv query by DOI failed', ex: ex, key: entry)
          end
        end

        unless entry[:arxiv] || entry[:doi]
          warning('No arXiv or DOI identifier found', key: entry)
        end
      end

    end
  end
end
