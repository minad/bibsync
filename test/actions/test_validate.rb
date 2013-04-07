require 'helper'

describe BibSync::Actions::Validate do
  let(:bib) do
    BibSync::Bibliography.new(File.join(fixturedir, 'test.bib'))
  end

  let(:action) do
    BibSync::Actions::Validate.new(bib: bib)
  end

  it 'should not raise an exception' do
    action.run
  end
end
