require 'active_support'
require 'active_support/core_ext'
require 'fileutils'

module Rubstone
  class Config
    attr_reader :cache_root
    attr_reader :lib_root
    attr_reader :directories
    attr_reader :tagged_directory_map

    def initialize(hash)
      hash.assert_valid_keys("cache_root", "lib_root", "directories")
      @cache_root = hash["cache_root"]
      @lib_root = hash["lib_root"]
      @directories = hash["directories"]
      raise "cache_root is not set" if @cache_root.blank?
      if @lib_root.blank? && @directories.blank?
        raise "lib_root or directories should be set"
      end
      if @directories.present?
        @tagged_directory_map = Rubstone::TaggedDirectoryMap.new(@directories)
      end
    end

    def mkdir_cache_root
      FileUtils.mkdir_p(cache_root)
    end

    def cache_path(name)
      File.join(cache_root, name)
    end

    def dest_lib_path(name)
      File.join(lib_root, name)
    end

    def repository_subdir(lib_name, subdir)
      File.join(cache_root, lib_name, subdir)
    end

    def copied_subdir(lib_name, tag)
      tagged_dir = @tagged_directory_map.tagged_directory(tag)
      if tagged_dir.ignore_lib_name
        tagged_dir.path
      else
        File.join(tagged_dir.path, lib_name)
      end
    end
  end
end
