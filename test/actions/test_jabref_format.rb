require 'helper'

describe BibSync::Actions::JabRefFormat do
  before do
    @tmpfile = File.join(fixturedir, 'tmp.bib')
    FileUtils.copy(File.join(fixturedir, 'test.bib'), @tmpfile)
  end

  after do
    File.unlink(@tmpfile) if File.exists?(@tmpfile)
  end

  let(:bib) do
    BibSync::Bibliography.new(@tmpfile)
  end

  let(:action) do
    BibSync::Actions::JabRefFormat.new(bib: bib)
  end

  it 'should format file' do
    action.run
    puts File.read(@tmpfile)
    File.read(@tmpfile).must_match(/created\s+with\s+JabRef/)
  end
end
