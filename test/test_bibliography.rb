require 'helper'

describe BibSync::Bibliography do
  let(:newbib) do
    BibSync::Bibliography.new
  end

  let(:bib) do
    BibSync::Bibliography.new(File.join(fixturedir, 'test.bib'))
  end

  describe '#initialize' do
    it 'creates unnamed bibliography' do
      BibSync::Bibliography.new.file.must_be_nil
    end

    it 'creates named bibliography' do
      BibSync::Bibliography.new('test.bib').file.must_equal 'test.bib'
    end

    it 'reads bibliography' do
      BibSync::Bibliography.new(File.join(fixturedir, 'test.bib')).empty?.must_equal false
    end
  end

  describe '#dirty?' do
    it 'must be false for new bibliography' do
      newbib.dirty?.must_equal false
    end

    it 'must be true after adding an entry' do
      bib << BibSync::Bibliography::Entry.new(key: 'test')
      bib.dirty?.must_equal true
    end

    it 'must be true after deleting an entry' do
      bib.delete(bib['TestBook'])
      bib.dirty?.must_equal true
    end

    it 'must be true after calling dirty!' do
      bib.dirty!
      bib.dirty?.must_equal true
    end
  end

  describe '#empty?' do
    it 'must be true for new bibliography' do
      newbib.empty?.must_equal true
    end

    it 'must be false for non-empty bibliography' do
      bib.empty?.must_equal false
    end

    it 'must be false after adding an entry' do
      newbib << BibSync::Bibliography::Entry.new(key: 'test')
      newbib.empty?.must_equal false
    end
  end

  describe '#size' do
    it 'must be 0 for new bibliography' do
      newbib.size.must_equal 0
    end

    it 'must increment after adding an entry' do
      size = bib.size
      bib << BibSync::Bibliography::Entry.new(key: 'test')
      bib.size.must_equal size + 1
    end
  end

  describe '#[]' do
    it 'must return nil for non-existing entry' do
      newbib['nonexisting'].must_be_nil
    end

    it 'must return entry' do
      bib['TestBook'].must_be_instance_of BibSync::Bibliography::Entry
      bib['TestBook'].key.must_equal 'TestBook'
    end
  end

  describe '#delete' do
    it 'must delete entry' do
      bib.delete(bib['TestBook'])
      bib['TestBook'].must_equal nil
    end
  end

  describe '#clear' do
    it 'must clear bibliography' do
      bib.clear
      bib.size.must_equal 0
    end
  end

  describe '#relative_path' do
    it 'must return relative path' do
      bib.relative_path(__FILE__).must_equal '../test_bibliography.rb'
    end
  end

  describe '#each' do
    it 'must iterate over entries' do
      found = false
      bib.each do |entry|
        entry.must_be_instance_of BibSync::Bibliography::Entry
        found = true
      end
      found.must_equal true
    end
  end

  describe '#save' do
  end

  describe '#<<' do
    it 'must support adding an entry' do
      entry = BibSync::Bibliography::Entry.new(key: 'test')
      bib << entry
      bib['test'].must_be_same_as entry
    end
  end

  describe '#load' do
  end

  describe '#load!' do
  end

  describe '#parse' do
  end

  describe '#to_s' do
  end
end

describe BibSync::Bibliography::Entry do
  describe '#self.parse' do
    it 'should parse entry' do
      entry = BibSync::Bibliography::Entry.parse(File.read(File.join(fixturedir, 'entry.bib')))
      entry.type.must_equal 'BOOK'
      entry.key.must_equal 'TestBook'
      entry[:title].must_equal 'BookTitle'
      entry[:publisher].must_equal 'BookPublisher'
      entry[:year].must_equal '2000'
      entry[:month].must_equal 'jan'
      entry[:month].must_be_instance_of BibSync::Bibliography::RawValue
      entry[:author].must_equal 'BookAuthor'
      entry[:volume].must_equal 'BookVolume'
    end
  end

  describe '#initialize' do
    it 'should not set type and key' do
      entry = BibSync::Bibliography::Entry.new
      entry.type.must_be_nil
      entry.key.must_be_nil
      entry[:author].must_be_nil
    end

    it 'should initialize fields' do
      entry = BibSync::Bibliography::Entry.new(type: 'ARTICLE', key: 'key', author: 'Daniel')
      entry.type.must_equal 'ARTICLE'
      entry.key.must_equal 'key'
      entry[:author].must_equal 'Daniel'
    end
  end

  describe '#file=' do
  end

  describe '#file' do
  end

  describe '#[]' do
  end

  describe '#[]=' do
  end

  describe '#delete' do
  end

  describe '#each' do
  end

  describe '#comment?' do
    it 'should return true for a comment entry' do
      BibSync::Bibliography::Entry.new(type: 'coMMent').comment?.must_equal true
    end

    it 'should return false for a non-comment entry' do
      BibSync::Bibliography::Entry.new.comment?.must_equal false
      BibSync::Bibliography::Entry.new(type: 'article').comment?.must_equal false
    end
  end

  describe '#dirty!' do
  end

  describe '#to_s' do
  end

  describe '#parse' do
    it 'should parse entry' do
      entry = BibSync::Bibliography::Entry.new
      entry.parse(File.read(File.join(fixturedir, 'entry.bib')))
      entry.type.must_equal 'BOOK'
      entry.key.must_equal 'TestBook'
      entry[:title].must_equal 'BookTitle'
      entry[:publisher].must_equal 'BookPublisher'
      entry[:year].must_equal '2000'
      entry[:month].must_equal 'jan'
      entry[:month].must_be_instance_of BibSync::Bibliography::RawValue
      entry[:author].must_equal 'BookAuthor'
      entry[:volume].must_equal 'BookVolume'
    end
  end
end
