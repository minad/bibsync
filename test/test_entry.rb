
describe BibSync::Entry do
  describe '#self.parse' do
    it 'should parse entry' do
      entry = BibSync::Entry.parse(File.read(File.join(fixturedir, 'entry.bib')))
      entry.type.must_equal 'BOOK'
      entry.key.must_equal 'TestBook'
      entry[:title].must_equal 'BookTitle'
      entry[:publisher].must_equal 'BookPublisher'
      entry[:year].must_equal '2000'
      entry[:month].must_equal 'jan'
      entry[:month].must_be_instance_of BibSync::Literal
      entry[:author].must_equal 'BookAuthor'
      entry[:volume].must_equal 'BookVolume'
    end
  end

  describe '#initialize' do
    it 'should not set type and key' do
      entry = BibSync::Entry.new
      entry.type.must_be_nil
      entry.key.must_be_nil
      entry[:author].must_be_nil
    end

    it 'should initialize fields' do
      entry = BibSync::Entry.new(type: 'ARTICLE', key: 'key', author: 'Daniel')
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

  describe '#size' do
  end

  describe '#empty?' do
  end

  describe '#comment?' do
    it 'should return true for a comment entry' do
      BibSync::Entry.new(type: 'coMMent').comment?.must_equal true
    end

    it 'should return false for a non-comment entry' do
      BibSync::Entry.new.comment?.must_equal false
      BibSync::Entry.new(type: 'article').comment?.must_equal false
    end
  end

  describe '#dirty!' do
  end

  describe '#to_s' do
  end

  describe '#parse' do
    it 'should parse entry' do
      entry = BibSync::Entry.new
      entry.parse(File.read(File.join(fixturedir, 'entry.bib')))
      entry.type.must_equal 'BOOK'
      entry.key.must_equal 'TestBook'
      entry[:title].must_equal 'BookTitle'
      entry[:publisher].must_equal 'BookPublisher'
      entry[:year].must_equal '2000'
      entry[:month].must_equal 'jan'
      entry[:month].must_be_instance_of BibSync::Literal
      entry[:author].must_equal 'BookAuthor'
      entry[:volume].must_equal 'BookVolume'
    end
  end
end
