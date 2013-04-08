module BibSync
  module Utils
    def name_without_ext(file)
      file =~ /\A(.*?)\.\w+\Z/
      $1
    end

    def fetch(url, headers = {})
      # open(url, headers) {|f| f.read }
      headers = headers.map {|k,v| '-H ' + Shellwords.escape("#{k}: #{v}") }.join(' ')
      result = `curl --stderr - -S -s -L #{headers} #{Shellwords.escape url}`
      raise result.chomp if $? != 0
      result
    end

    def arxiv_download(dir, id)
      url = "http://arxiv.org/pdf/#{id}"
      file = File.join(dir, "#{arxiv_id(id, version: true, prefix: false)}.pdf")
      result = `curl --stderr - -S -s -L -o #{Shellwords.escape file} #{Shellwords.escape url}`
      raise result.chomp if $? != 0
    end

    def fetch_xml(url, headers = {})
      xml = Nokogiri::XML(fetch(url, headers))
      xml.remove_namespaces!
      xml
    end

    def fetch_html(url, headers = {})
      Nokogiri::HTML(fetch(url, headers))
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
