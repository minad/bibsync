require 'helper'

describe BibSync::Utils do
  include BibSync::Utils

  describe '#name_without_ext' do
    it 'returns name without extension' do
      name_without_ext('name.ext').must_equal 'name'
    end
  end

  describe '#fetch' do
    it 'fetches page' do
      fetch('http://google.com/').include?('<title>Google</title>').must_equal true
    end

    it 'fetches page with header' do
      fetch('http://dx.doi.org/10.1098/rspa.1984.0023', 'Accept' => 'text/bibliography; style=bibtex').include?('Berry').must_equal true
    end
  end

  describe '#arxiv_download' do
  end

  describe '#fetch_xml' do
    it 'fetches xml' do
      fetch_xml('http://export.arxiv.org/oai2?verb=GetRecord&identifier=oai:arXiv.org:1208.2881&metadataPrefix=arXiv').must_be_instance_of Nokogiri::XML::Document
    end
  end

  describe '#fetch_html' do
    it 'fetches html' do
      fetch_html('http://google.com').must_be_instance_of Nokogiri::HTML::Document
    end
  end

  describe '#arxiv_id' do
    it 'removes version from arxiv id' do
      arxiv_id('1234.5678v1', version: false, prefix: false).must_equal '1234.5678'
    end

    it 'keeps version from arxiv id' do
      arxiv_id('1234.5678v1', version: true, prefix: false).must_equal '1234.5678v1'
    end

    it 'removes prefix from arxiv id' do
      arxiv_id('prefix/1234v1', version: false, prefix: false).must_equal '1234'
    end

    it 'keeps prefix from arxiv id' do
      arxiv_id('prefix/1234v1', version: false, prefix: true).must_equal 'prefix/1234'
    end
  end
end
