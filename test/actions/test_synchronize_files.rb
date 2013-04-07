require 'helper'

describe BibSync::Actions::SynchronizeFiles do
  before do
    @tmpdir = File.join(fixturedir, 'tmp')
    FileUtils.mkdir(@tmpdir)
  end

  after do
    FileUtils.rm_rf(@tmpdir)
  end

  let(:bib) do
    BibSync::Bibliography.new(File.join(@tmpdir, 'test.bib'))
  end

  let(:action) do
    BibSync::Actions::SynchronizeFiles.new(bib: bib, dir: @tmpdir)
  end

  it 'should synchronize files' do
    10.times do |i|
      bib << BibSync::Bibliography::Entry.new(key: i) if i % 2 == 0
      FileUtils.touch(File.join(@tmpdir, "#{i}.pdf"))
    end
    bib.size.must_equal 5
    action.run
    bib.size.must_equal 10
    10.times do |i|
      bib[i].file[:name].must_equal "#{i}.pdf"
    end
  end
end
