require 'helper'

describe BibSync::Actions::SynchronizeMetadata do
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
    BibSync::Actions::SynchronizeMetadata.new(bib: bib)
  end

  it 'should download metadata' do
    entry = fixturebib['HasArXiv']
    bib << entry
    action.run
    entry[:title].must_equal 'Chirality Induced Tilted-Hill Giant Nernst Signal'
    entry[:journal].must_equal 'Physical Review Letters'
    entry[:doi].must_equal '10.1103/PhysRevLett.104.106404'
    entry[:arxiv].must_equal '0911.2512v3'
    entry[:url].must_match(/dx\.doi\.org/)
  end
end
