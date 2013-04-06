require 'helper'

describe BibSync::Bibliography do
  it 'can be created without an argument' do
    bib = BibSync::Bibliography.new
    bib.dirty?.must_equal false
  end

  it 'can be created without an argument' do
    bib = BibSync::Bibliography.new
    bib.dirty?.must_equal false
  end
end
