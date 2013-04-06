module BibSync
  module Actions
    class FetchFromArXiv
      SliceSize = 20

      include Log
      include Utils

      def initialize(options)
        raise 'Option :fetch is required' unless @fetch = options[:fetch]
        raise 'Option :dir is required' unless @dir = options[:dir]
      end

      def run
        arxivs = []
        urls = []

        @fetch.each do |url|
          if url =~ /\A(\d+\.\d+)(v\d+)?\Z/
            arxivs << $1
          elsif url =~ %r{\Ahttp://arxiv.org/abs/(\d+\.\d+)\Z}
            arxivs << $1
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

        unless arxivs.empty?
          notice 'Downloading from arXiv'
          arxivs.each_slice(SliceSize) do |ids|
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
