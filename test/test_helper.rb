require 'simplecov'

SimpleCov.start do
  add_filter 'test'
  project_name 'Bzip2::FFI'
end

require 'bzip2/ffi'
require 'fileutils'
require 'minitest/autorun'
require 'open3'

module TestHelper
  BASE_DIR = File.expand_path(File.dirname(__FILE__))

  module Assertions
    def assert_files_identical(exp, act, msg = nil)
      msg = message(msg) { "Expected file #{act} to be identical to #{exp}" }
      assert(FileUtils.identical?(exp, act), msg)
    end

    def assert_bzip2_successful(arguments)
      out, err, status = Open3.capture3("bzip2 #{arguments}")

      assert(status.exitstatus == 0, "`bzip2 #{arguments}` exit status was non-zero")
      assert(out == '', "`bzip2 #{arguments}` returned output: #{out}")
      assert(err == '', "`bzip2 #{arguments}` returned error: #{err}")
    end

    def assert_bunzip2_successful(arguments)
      assert_bzip2_successful("--decompress #{arguments}")
    end
  end

  module Fixtures
    FIXTURES_DIR = File.join(BASE_DIR, 'fixtures')
  
    def fixture_path(fixture)
      File.join(FIXTURES_DIR, fixture)
    end
  end
end

class Minitest::Test
  include TestHelper::Assertions
  include TestHelper::Fixtures
end
