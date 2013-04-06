require 'minitest/spec'
require 'minitest/autorun'
require 'bibsync'
require 'fileutils'

module Helper
  def tmpdir
    dir = File.join(File.dirname(__FILE__), 'tmp')
    FileUtils.mkdir(dir)
    dir
  end

  def fixturedir
    FileUtils.join(File.dirname(__FILE__), 'fixtures')
  end
end

class MiniTest::Spec
  include Helper

  after do
    FileUtils.rm_rf(File.join(File.dirname(__FILE__), 'tmp'))
  end
end
