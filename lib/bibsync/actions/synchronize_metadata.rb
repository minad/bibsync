module BibSync
  module Actions
    class SynchronizeMetadata
      include Utils
      include Log

      def initialize(options)
        raise 'Bibliography must be set' unless @bib = options[:bib]
        @force = options[:resync]
      end

      def run
        notice 'Synchronize with arXiv and DOI'

        @bib.each do |entry|
          next if entry.comment?

          if @force || !(entry[:title] && entry[:author] && entry[:year])
            determine_arxiv_and_doi(entry)

            if entry[:arxiv]
              if entry.key == arxiv_id(entry, :prefix => false, :version => true)
                entry = rename_arxiv_file(entry)
                next unless entry
              end
              update_arxiv(entry)
            end

            update_doi(entry) if entry[:doi]
          end

          if @force || (!entry[:abstract] && entry[:doi] =~ /\A10\.1103\//)
            update_aps_abstract(entry)
          end

          @bib.save
        end
      end

      private

      def update_aps_abstract(entry)
        info("Downloading APS abstract", :key => entry)
        html = fetch_html("http://link.aps.org/doi/#{entry[:doi]}")
        entry[:abstract] = html.css('.aps-abstractbox').map(&:content).first
      rescue => ex
        error('Abstract download failed', :key => entry, :ex => ex)
      end

      def update_doi(entry)
        info('Downloading DOI metadata', :key => entry)
        text = fetch("http://dx.doi.org/#{entry[:doi]}", 'Accept' => 'text/bibliography; style=bibtex')
        raise text if text == 'Unknown DOI'
        Bibliography::Entry.parse(text).each {|k, v| entry[k] = v }
      rescue => ex
        entry.delete(:doi)
        error('DOI download failed', :key => entry, :ex => ex)
      end

      # Rename arxiv file if key contains version
      def rename_arxiv_file(entry)
        file = entry.file

        key = arxiv_id(entry, :prefix => false, :version => false)

        if old_entry = @bib[key]
          # Existing entry found
          @bib.delete(entry)
          old_entry[:arxiv] =~ /v(\d+)$/
          old_version = $1
          entry[:arxiv] =~ /v(\d+)$/
          new_version = $1
          if old_version && new_version && old_version >= new_version
            info('Not updating existing entry with older version', :key => old_entry)
            File.delete(file[:path]) if file
            return nil
          end

          old_entry[:arxiv] = entry[:arxiv]
          old_entry[:doi] = entry[:doi]
          entry = old_entry
          info('Updating existing entry', :key => entry)
        else
          # This is a new entry
          entry.key = key
        end

        if file
          new_path = file[:path].sub(arxiv_id(entry, :prefix => false, :version => true), key)
          File.rename(file[:path], new_path)
          entry.file = new_path
        end

        @bib.save

        entry
      end

      def update_arxiv(entry)
        info('Downloading arXiv metadata', :key => entry)
        xml = fetch_xml("http://export.arxiv.org/oai2?verb=GetRecord&identifier=oai:arXiv.org:#{arxiv_id(entry, :prefix => true, :version => false)}&metadataPrefix=arXiv")
        error = xml.xpath('//error').map(&:content).first
        raise error if error

        entry[:title] = xml.xpath('//arXiv/title').map(&:content).first
        entry[:abstract] = xml.xpath('//arXiv/abstract').map(&:content).first
        entry[:primaryclass] = xml.xpath('//arXiv/categories').map(&:content).first.split(/\s+/).first
        entry[:author] = xml.xpath('//arXiv/authors/author').map do |author|
          "{#{author.xpath('keyname').map(&:content).first}}, {#{author.xpath('forenames').map(&:content).first}}"
        end.join(' and ')
        entry[:journal] = 'ArXiv e-prints'
        entry[:eprint] = entry[:arxiv]
        entry[:archiveprefix] = 'arXiv'
        date = xml.xpath('//arXiv/updated').map(&:content).first || xml.xpath('//arXiv/created').map(&:content).first
        date = Date.parse(date)
        entry[:year] = date.year
        entry[:month] = Bibliography::RawValue.new(%w(jan feb mar apr may jun jul aug sep oct nov dec)[date.month - 1])
        doi = xml.xpath('//arXiv/doi').map(&:content).first
        entry[:doi] = doi if doi
        journal = xml.xpath('//arXiv/journal-ref').map(&:content).first
        entry[:journal] = journal if journal
        comments = xml.xpath('//arXiv/comments').map(&:content).first
        entry[:comments] = comments if comments
        entry[:url] = "http://arxiv.org/abs/#{entry[:arxiv]}"
      rescue => ex
        entry.delete(:arxiv)
        error('arXiv download failed', :key => entry, :ex => ex)
      end

      def determine_arxiv_and_doi(entry)
        if file = entry.file
          if file[:type] == :PDF && !entry[:arxiv] && !entry[:doi]
            debug('Searching for arXiv or doi identifier in pdf file', :key => entry)
            text = `pdftotext -f 1 -l 2 #{Shellwords.escape file[:path]} - 2>/dev/null`
            entry[:arxiv] = $1 if text =~ /arXiv:\s*([\w\.\/\-]+)/
            entry[:doi] = $1 if text =~ /doi:\s*([\w\.\/\-]+)/i
          end

          if !entry[:arxiv] && file[:name] =~ /^(\d+.\d+v\d+)\.\w+$/
            debug('Interpreting file name as arXiv identifier', :key => entry)
            entry[:arxiv] = $1
          end

          if !entry[:doi] && file[:name] =~ /^(PhysRev.*?|RevModPhys.*?)\.\w+$/
            debug('Interpreting file name as doi identifier', :key => entry)
            entry[:doi] = "10.1103/#{$1}"
          end
        end

        if !entry[:arxiv] && entry[:doi]
          begin
            info('Fetch missing arXiv identifier', :key => entry)
            xml = fetch_xml("http://export.arxiv.org/api/query?search_query=doi:#{entry[:doi]}&max_results=1")
            if xml.xpath('//entry/doi').map(&:content).first == entry[:doi]
              id = xml.xpath('//entry/id').map(&:content).first
              if id =~ %r{\Ahttp://arxiv.org/abs/(.+)\Z}
                entry[:arxiv] = $1
              end
            end
          rescue => ex
            error('arXiv query by DOI failed', :ex => ex, :key => entry)
          end
        end

        unless entry[:arxiv] || entry[:doi]
          warning('No arXiv or DOI identifier found', :key => entry)
        end
      end

    end
  end
end
