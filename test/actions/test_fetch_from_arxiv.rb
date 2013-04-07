require 'helper'

describe BibSync::Actions::FetchFromArXiv do
  before do
    @tmpdir = File.join(testdir, 'tmp')
    FileUtils.mkdir(@tmpdir)
  end

  after do
    FileUtils.rm_rf(@tmpdir)
  end

  let(:action) do
    BibSync::Actions::FetchFromArXiv.new(dir: @tmpdir, fetch: %w(0911.2512v1 http://arxiv.org/abs/0911.1461))
  end

  it 'should download files' do
    action.run
    File.exists?(File.join(@tmpdir, '0911.2512v3.pdf')).must_equal true
    File.exists?(File.join(@tmpdir, '0911.1461v3.pdf')).must_equal true
  end
end
