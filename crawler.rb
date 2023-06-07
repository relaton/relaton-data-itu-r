# frozen_string_literal: true

require 'relaton_itu'

FileUtils.rm_rf 'data'
FileUtils.rm Dir.glob('index*')

RelatonItu::DataFetcher.fetch
