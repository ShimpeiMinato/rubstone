require 'active_support'
require 'active_support/core_ext'

module Rubstone
  class Library
    attr_reader :name
    attr_reader :repository
    attr_reader :ref
    attr_reader :config

    def initialize(hash, config)
      hash.assert_valid_keys("name", "repository", "ref", "lib_root")
      @name = hash["name"]
      @repository = hash["repository"]
      @ref = hash["ref"]
      @lib_root = hash["lib_root"]
      raise "name is not set" if @name.blank?
      raise "repository is not set" if @repository.blank?
      raise "ref is not set" if @ref.blank?
      raise "lib_root is not set" if @lib_root.blank?

      @config = config
    end

    def update_cache
      if File.exist? cache_path
        git_action.pull
        git_action.checkout_ref(ref)
      else
        git_action.git_clone(repository)
        git_action.checkout_ref(ref)
      end
    end

    private

    def git_action
      Rubstone::GitAction.new(cache_path)
    end

    def cache_path
      @config.cache_path(name)
    end

    def directory_relations
      [Rubstone::DirectoryRelation.new(cache_lib_path, dest_lib_path)]
    end

    public

    def copy_lib
      Rubstone::CopyLibrary.new(self).copy_lib
    end

    def delete_removed_files
      directory_relation = directory_relations.first

      dest_files = Dir.glob(File.join(dest_lib_path, "**/*")).reject{ |fn|
        File.extname(fn) == ".meta"
      }
      delete_files = dest_files.reject{ |fn|
        relative_path = fn.sub(dest_lib_path, '')
        File.exist? File.join(cache_lib_path, relative_path)
      }

      delete_files.each do |f|
        system("rm -rf #{f}")
        system("rm -rf #{f}.meta")
      end
    end

    def cache_lib_path
      File.join(cache_path, lib_root)
    end

    def dest_lib_path
      @config.dest_lib_path(name)
    end

    private

    def lib_root
      @lib_root
    end

    public

    def dev_import
      dest_lib_directory = dest_lib_path.end_with?("/") ? dest_lib_path : "#{dest_lib_path}/"
      system("rm -rf #{cache_lib_path}")
      system("cp -R #{dest_lib_directory} #{cache_lib_path}")
      meta_files = Dir.glob(File.join(cache_lib_path, "**/*")).select{|f|
        File.extname(f) == ".meta"
      }
      meta_files.each do |f|
        system("rm #{f}")
      end
    end
  end
end

