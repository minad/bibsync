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
      bib << BibSync::Entry.new(key: 'test')
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
      newbib << BibSync::Entry.new(key: 'test')
      newbib.empty?.must_equal false
    end
  end

  describe '#size' do
    it 'must be 0 for new bibliography' do
      newbib.size.must_equal 0
    end

    it 'must increment after adding an entry' do
      size = bib.size
      bib << BibSync::Entry.new(key: 'test')
      bib.size.must_equal size + 1
    end
  end

  describe '#[]' do
    it 'must return nil for non-existing entry' do
      newbib['nonexisting'].must_be_nil
    end

    it 'must return entry' do
      bib['TestBook'].must_be_instance_of BibSync::Entry
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
        entry.must_be_instance_of BibSync::Entry
        found = true
      end
      found.must_equal true
    end
  end

  describe '#save' do
  end

  describe '#<<' do
    it 'must support adding an entry' do
      entry = BibSync::Entry.new(key: 'test')
      bib << entry
      bib['test'].must_be_same_as entry
    end
  end

  describe '#load' do
  end

  describe '#parse' do
  end

  describe '#to_s' do
  end
end
