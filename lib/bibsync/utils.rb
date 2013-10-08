module BibSync
  module Utils
    def name_without_ext(file)
      file =~ /\A(.*?)\.\w+\Z/
      $1
    end

    def fetch(url, params = nil, headers = nil)
      client = Faraday.new(url) do |c|
        c.use FaradayMiddleware::FollowRedirects, limit: 3
        c.use Faraday::Response::RaiseError
        c.use Faraday::Adapter::NetHttp
      end
      response = client.get(url, params, headers)
      raise "HTTP error #{response.status}" unless response.status == 200
      body = response.body
      encoding = body.encoding
      body.force_encoding(Encoding::UTF_8)
      body.force_encoding(encoding) unless body.valid_encoding?
      body
    end

    def arxiv_download(dir, id)
      File.open(File.join(dir, "#{arxiv_id(id, version: true, prefix: false)}.pdf"), 'wb') do |o|
        o.write(fetch("http://arxiv.org/pdf/#{id}"))
      end
    end

    def fetch_xml(url, params = nil, headers = nil)
      REXML::Document.new(fetch(url, params, headers)).root
    end

    def arxiv_id(arxiv, opts = {})
      raise unless opts.include?(:prefix) && opts.include?(:version)
      arxiv = arxiv[:arxiv] if Entry === arxiv
      if arxiv
        arxiv = arxiv.sub(/\A.*\//, '') unless opts[:prefix]
        arxiv = arxiv.sub(/v\d+\Z/, '') unless opts[:version]
      end
      arxiv
    end
  end
end
