require 'helper'

describe BibSync::Bibliography do
  it 'can be created without an argument' do
    bib = BibSync::Bibliography.new
    bib.dirty?.must_equal false
    bib.empty?.must_equal true
    bib.size.must_equal 0
    bib.file.must_equal nil
  end

  it 'can be created with non-existing file' do
    file = File.join(tmpdir, 'test.bib')
    bib = BibSync::Bibliography.new(file)
    bib.dirty?.must_equal false
    bib.empty?.must_equal true
    bib.size.must_equal 0
    bib.file.must_equal file
  end

  it 'can be saved' do
    file = File.join(tmpdir, 'test.bib')
    bib = BibSync::Bibliography.new
    bib.file.must_equal nil
    bib.save(file)
    bib.file.must_equal file
  end

  it 'reads entries' do

  end

  it 'saves entries' do

  end

  it 'adds entries' do
  end

  it 'deletes entries' do
  end

  it 'has a method #relative_path' do
  end

  it 'has a method #each' do
  end

  it 'has method #parse' do
  end
end
