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

    new_sopm = sopm.parse
    assert_equal 2, new_sopm['change_log'].count

    new_sopm = sopm.version('1.1.1', 'a comment 1')
    assert_equal 3, new_sopm['change_log'].count

    new_sopm = sopm.version('1.1.2', 'a comment 2')
    assert_equal 4, new_sopm['change_log'].count
  end

  def test_version_version_delete_latest_by_nil
    sopm = OTRS::SOPM.new 'test/testfiles/TestFile.sopm'

    new_sopm = sopm.version_delete()

    assert_equal 1, new_sopm['change_log'].count
    assert_equal '1.0.0', new_sopm['change_log'].first['version']
    assert_equal 'Previous version.', new_sopm['change_log'].first['log']
  end

  def test_version_version_delete_latest_by_number
    sopm = OTRS::SOPM.new 'test/testfiles/TestFile.sopm'

    new_sopm = sopm.version_delete('1.0.1')

    assert_equal 1, new_sopm['change_log'].count
    assert_equal '1.0.0', new_sopm['change_log'].first['version']
    assert_equal 'Previous version.', new_sopm['change_log'].first['log']
  end

  def test_version_version_delete_previous
    sopm = OTRS::SOPM.new 'test/testfiles/TestFile.sopm'

    new_sopm = sopm.version_delete('1.0.0')

    assert_equal 1, new_sopm['change_log'].count
    assert_equal '1.0.1', new_sopm['change_log'].first['version']
    assert_equal 'Latest version.', new_sopm['change_log'].first['log']
  end
end
