module BibSync
  module Actions
    class FetchFromArXiv
      SliceSize = 20

      include Log
      include Utils

      def initialize(options)
        raise 'Fetch must be set' unless @fetch = options[:fetch]
        raise 'Directory must be set' unless @dir = options[:dir]
      end

      def run
        ids = []
        urls = []

        @fetch.each do |url|
          if url =~ %r{^http://arxiv.org/abs/(\d+\.\d+)$}
            ids << $1
          else
            urls << url
          end
        end

        unless urls.empty?
          notice 'Starting browser for non-arXiv urls'
          urls.each do |url|
            info "Opening #{url}"
            `xdg-open #{Shellwords.escape url}`
          end
        end

        unless ids.empty?
          notice 'Downloading from arXiv'
          ids.each_slice(SliceSize) do |ids|
            begin
              xml = fetch_xml("http://export.arxiv.org/api/query?id_list=#{ids.join(',')}&max_results=#{SliceSize}")
              xml.xpath('//entry/id').map(&:content).each_with_index do |id, i|
                id.gsub!('http://arxiv.org/abs/', '')
                info 'arXiv download', :key => id
                arxiv_download(@dir, id)
              end
            rescue => ex
              error('arXiv query failed', :ex => ex)
            end
          end
        end
      end
    end
  end
end
