module BibSync
  module Actions
    class CheckArXivVersions
      include Log
      include Utils

      SliceSize = 20

      def initialize(options)
        raise 'Option --bib is required' unless @bib = options[:bib]
        raise 'Option --dir is required' unless @dir = options[:dir]
        @update = options[:update]
      end

      def run
        notice 'Check for newer version on arXiv'
        @bib.select {|e| e[:arxiv] }.each_slice(SliceSize) do |entry|
          begin
            xml = fetch_xml('http://export.arxiv.org/api/query', id_list: entry.map{|e| arxiv_id(e, version: false, prefix: true) }.join(','), max_results: SliceSize)
            xml.xpath('//entry/id').map(&:content).each_with_index do |id, i|
              id.gsub!('http://arxiv.org/abs/', '')
              if id != entry[i][:arxiv]
                info("#{entry[i][:arxiv]} replaced by http://arxiv.org/pdf/#{id}", key: entry[i])
                arxiv_download(@dir, id) if @update
              end
            end
          rescue => ex
            error('arXiv query failed', ex: ex)
          end
        end

      end
    end
  end
end
