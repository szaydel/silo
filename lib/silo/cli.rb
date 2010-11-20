# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2010, Sebastian Staudt

require 'rubygems'
require 'rubikon'

module Silo

  # This class is a Rubikon application that implements the command-line
  # interface for Silo
  #
  # @author Sebastian Staudt
  # @since 0.1.0
  class CLI < Rubikon::Application::Base

    set :config_file, '.silo'
    set :config_format, :ini
    set :help_banner, 'Usage: silo'

    pre_execute do
      @repo_path = config['repository']['path']
    end

    default do
      puts "This is Silo. A Git-based backup utility.\n\n"
      call :help
    end

    option :prefix, [:path]
    command :add, -1, 'Store one or more files in the repository' do
      repo = Repository.new @repo_path
      args.each do |file|
        repo.add file, prefix.path
      end
    end

    command :init, 0..1, 'Initialize a Silo repository' do
      args[0] = File.dirname(__FILE__) if args[0].nil?
      puts "Initializing Silo repository in #{File.expand_path args[0]}..."
      Repository.new args[0]
    end

    command :remote, 0..-1, 'Add or remove remote repositories' do
      repo = Repository.new @repo_path
      usage = lambda do
        puts 'usage: silo remote add <name> <url>'
        puts '   or: silo remote rm <name>'
      end
      case args[0]
        when 'add':
          if args.size == 3
            repo.add_remote args[1], args[2]
          else
            usage.call
          end
        when 'rm':
          if args.size == 2
            repo.remove_remote args[1]
          else
            usage.call
          end
        else
          usage.call
      end
    end

    option :prefix, [:path]
    command :restore, -1, 'Restore one or more files or directories from the repository' do
      repo = Repository.new @repo_path
      args.each do |file|
        repo.restore file, prefix.path
      end
    end

  end

end
