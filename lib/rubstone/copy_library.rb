require 'fileutils'

module Rubstone
  class CopyLibrary
    def initialize(library)
      @library = library
      @config = @library.config
    end

    def copy_lib(excludes=[])
      @library.directory_relations.each do |rel|
        copy_dir(rel.repository_dir, rel.copied_dir, rel.ignore_delete, excludes + rel.exclusions)
      end
    end

    def reverse_copy_lib(excludes=[])
      @library.directory_relations.each do |rel|
        copy_dir(rel.copied_dir, rel.repository_dir, rel.ignore_delete, excludes + rel.exclusions)
      end
    end

    def copy_dir(src_path, dst_path, ignore_delete, excludes=[])
      FileUtils.mkdir_p(File.dirname(src_path))
      FileUtils.mkdir_p(File.dirname(dst_path))
      local_excludes = excludes + [".git"]
      src_path = src_path.end_with?("/") ? src_path : "#{src_path}/"
      args = []
      args += ["-a"]
      args += local_excludes.map{|e| %Q(--exclude="#{e}")}
      args += ["--delete"] unless ignore_delete
      args += [%Q("#{src_path}")]
      args += [%Q("#{dst_path}")]
      command = (["rsync"] + args).join(" ")
      puts command
      system(command)
    end
  end
end
