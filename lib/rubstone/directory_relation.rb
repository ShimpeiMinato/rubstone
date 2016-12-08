require 'fileutils'

module Rubstone
  class DirectoryRelation
    attr_reader :repository_dir
    attr_reader :copied_dir
    attr_reader :ignore_delete
    attr_reader :exclusions

    def initialize(repository_dir, copied_dir, ignore_delete=false, exclusions=[])
      @repository_dir = repository_dir
      @copied_dir = copied_dir
      @ignore_delete = ignore_delete
      @exclusions = exclusions
    end
  end
end
