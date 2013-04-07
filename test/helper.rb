require 'minitest/spec'
require 'minitest/autorun'
require 'bibsync'
require 'fileutils'

BibSync::Log.level = :error
BibSync::Log.trace = true

module Helper
  def testdir
    File.dirname(__FILE__)
  end

  def fixturedir
    File.join(testdir, 'fixture')
  end
end

class MiniTest::Spec
  include Helper

  after do
    FileUtils.rm_rf(File.join(File.dirname(__FILE__), 'tmp'))
  end
end
