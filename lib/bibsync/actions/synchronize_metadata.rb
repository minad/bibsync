module BibSync
  module Actions
    class SynchronizeMetadata
      include Utils
      include Log

      def initialize(options)
        raise 'Option --bib is required' unless @bib = options[:bib]
        @force = options[:resync]
      end

      def run
        notice 'Synchronize with arXiv and DOI'

        @bib.to_a.each do |entry|
          next if entry.comment?

          if @force || !(entry[:title] && entry[:author] && entry[:year])
            if entry[:arxiv]
              if entry.key == arxiv_id(entry, prefix: false, version: true)
                entry = rename_arxiv_file(entry)
                next unless entry
              end
              update_arxiv(entry)
            end

            update_doi(entry) if entry[:doi]
          end

          if entry[:doi] =~ /\A10\.1103\// && (@force || !entry[:abstract])
            update_aps_abstract(entry)
          end

          @bib.save
        end

        # Add timestamp when this entry was added
        @bib.to_a.each do |entry|
          next if entry.comment?
          entry[:added] ||= Date.today.to_s
        end
        @bib.save
      end

      private

      def update_aps_abstract(entry)
        info("Downloading APS abstract", key: entry)
        html = fetch("http://link.aps.org/doi/#{entry[:doi]}")
        if html =~ %r{<div class='aps-abstractbox'>(.*?)</div>}
          entry[:abstract] = $1.gsub(/<[^>]+>/, '')
        end
      rescue => ex
        error('Abstract download failed', key: entry, ex: ex)
      end

      def update_doi(entry)
        url = "http://dx.doi.org/#{entry[:doi]}"
        info("Downloading DOI metadata from #{url}", key: entry)
        text = fetch(url, nil, 'Accept' => 'text/bibliography; style=bibtex')
        raise text if text == 'Unknown DOI'
        Entry.parse(text).each {|k, v| entry[k] = v }
      rescue => ex
        error('DOI download failed', key: entry, ex: ex)
        # dx.doi.org shows spurious 500 errors
        if ex.respond_to?(:response) && ex.response[:status] == 500
          tries ||= 0
          tries += 1
          if tries < 10
            info('Retrying...', key: entry)
            retry
          else
            error('Giving up :(', key: entry)
          end
        end
        entry.delete(:doi)
      end

      # Rename arxiv file if key contains version
      def rename_arxiv_file(entry)
        file = entry.file

        key = arxiv_id(entry, prefix: false, version: false)

        if old_entry = @bib[key]
          # Existing entry found
          @bib.delete(entry)
          old_entry[:arxiv] =~ /v(\d+)$/
          old_version = $1
          entry[:arxiv] =~ /v(\d+)$/
          new_version = $1
          if old_version && new_version && old_version >= new_version
            info('Not updating existing entry with older version', key: old_entry)
            File.delete(file[:path]) if file
            return nil
          end

          old_entry[:arxiv] = entry[:arxiv]
          old_entry[:doi] = entry[:doi]
          entry = old_entry
          info('Updating existing entry', key: entry)
        else
          # This is a new entry
          entry.key = key
        end

        if file
          new_path = file[:path].sub(arxiv_id(entry, prefix: false, version: true), key)
          File.rename(file[:path], new_path)
          entry.file = new_path
        end

        @bib.save

        entry
      end

      def update_arxiv(entry)
        info('Downloading arXiv metadata', key: entry)

        xml = fetch_xml('http://export.arxiv.org/oai2', verb: 'GetRecord', identifier: "oai:arXiv.org:#{arxiv_id(entry, prefix: true, version: false)}", metadataPrefix: 'arXiv')
        error = find_key(xml, 'error')
        raise error.first unless error.empty?

        arXiv = find_key(xml, 'arXiv').first

        entry[:title] = arXiv['title']
        entry[:abstract] = arXiv['abstract']
        entry[:arxivcategories] = arXiv['categories']
        entry[:primaryclass] = entry[:arxivcategories].split(/\s+/).first
        entry[:author] = [arXiv['authors']['author']].flatten.map do |author|
          "{#{author['keyname']}}, {#{author['forenames']}}"
        end.join(' and ')
        entry[:journal] = 'ArXiv e-prints'
        entry[:eprint] = entry[:arxiv]
        entry[:archiveprefix] = 'arXiv'
        entry[:arxivcreated] = arXiv['created']
        entry[:arxivupdated] = arXiv['updated']
        date = Date.parse(entry[:arxivupdated] || entry[:arxivcreated])
        entry[:year] = date.year
        entry[:month] = Literal.new(%w(jan feb mar apr may jun jul aug sep oct nov dec)[date.month - 1])
        entry[:doi] = arXiv['doi'] if arXiv['doi']
        entry[:journal] = arXiv['journal-ref'] if arXiv['journal-ref']
        entry[:comments] = arXiv['comments'] if arXiv['comments']
        entry[:url] = "http://arxiv.org/abs/#{entry[:arxiv]}"
      rescue => ex
        entry.delete(:arxiv)
        error('arXiv download failed', key: entry, ex: ex)
      end
    end
  end
end
