# frozen_string_literal: true

require 'relaton_itu'

FileUtils.rm_rf 'data'
FileUtils.rm Dir.glob('index*')

RelatonItu::DataFetcher.fetch

system 'zip index-v1.zip index-v1.yaml'
system 'git add index-v1.zip index-v1.yaml'
