require 'minitest/autorun'
require 'otrs/sopm'

class OtrsSopmTest < Minitest::Test

  def setup
    FileUtils.cp 'test/fixtures/TestFile.sopm', 'test/testfiles/TestFile.sopm'
  end

  def test_init_file_ok
    sopm = OTRS::SOPM.new 'test/testfiles/TestFile.sopm'
    refute_nil( sopm, 'got a sopm' )
  end

  def test_init_file_not_ok
    assert_raises Errno::ENOENT do
      sopm = OTRS::SOPM.new 'test/testfiles/TestFileNotFound.sopm'
    end
  end

  def test_version_wrong_version_parameter
    sopm = OTRS::SOPM.new 'test/testfiles/TestFile.sopm'
    assert_raises ArgumentError do
      sopm.version(1, 'Added exception handling to fopen.')
    end
    assert_raises ArgumentError do
      sopm.version('1', 'Just a really short version.')
    end
    assert_raises ArgumentError do
      sopm.version('1.1', 'Just a short version.')
    end
    assert_raises ArgumentError do
      sopm.version('1.1.1.1.1', 'Just a really long version.')
    end
  end

  def test_version_wrong_comment_parameter
    sopm = OTRS::SOPM.new 'test/testfiles/TestFile.sopm'
    assert_raises ArgumentError do
      sopm.version('1.1.1', 1)
    end
  end

  def test_version_add_version
    sopm = OTRS::SOPM.new 'test/testfiles/TestFile.sopm'
    newSopm = sopm.parse
    assert_nil newSopm['change_log']
    sopm.version('1.1.1', 'a comment 1')
    newSopm = sopm.parse
    assert_equal newSopm['change_log'].count, 1
    sopm.version('1.1.2', 'a comment 2')
    newSopm = sopm.parse
    assert_equal newSopm['change_log'].count, 2
  end

  def test_version_wrong_format

  end
end
