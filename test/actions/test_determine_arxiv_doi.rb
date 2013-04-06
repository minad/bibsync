require 'helper'

describe BibSync::Actions::DetermineArXivDOI do
  before do
    @tmpfile = File.join(fixturedir, 'tmp.bib')
  end

  after do
    File.unlink(@tmpfile) if File.exists?(@tmpfile)
  end

  let(:bib) do
    BibSync::Bibliography.new(@tmpfile)
  end

  let(:fixturebib) do
    BibSync::Bibliography.new(File.join(fixturedir, 'test.bib'))
  end

  let(:action) do
    BibSync::Actions::DetermineArXivDOI.new(bib: bib)
  end

  it 'should find arXiv identifier in pdf file' do
    entry = fixturebib['FileWithEmbeddedArXiv']
    bib << entry
    action.run
    entry[:arxiv].must_equal '0911.2512v3'
  end

  it 'should find DOI identifier in file and add missing arXiv identifier' do
    entry = fixturebib['FileWithEmbeddedDOI']
    bib << entry
    action.run
    entry[:arxiv].must_equal '0911.2512v3'
    entry[:doi].must_equal '10.1103/PhysRevLett.104.106404'
  end

  it 'should interpret file name as arXiv identifier' do
    entry = fixturebib['0911.2512v3']
    bib << entry
    action.run
    entry[:arxiv].must_equal '0911.2512v3'
  end

  it 'should interpret file name as DOI identifier and add missing arXiv identifier' do
    entry = fixturebib['PhysRevLett.104.106404']
    bib << entry
    action.run
    entry[:arxiv].must_equal '0911.2512v3'
    entry[:doi].must_equal '10.1103/PhysRevLett.104.106404'
  end

  it 'should add missing arXiv identifier' do
    entry = fixturebib['HasDOI']
    bib << entry
    entry[:doi].must_equal '10.1103/PhysRevLett.104.106404'
    action.run
    entry[:arxiv].must_equal '0911.2512v3'
  end
end
