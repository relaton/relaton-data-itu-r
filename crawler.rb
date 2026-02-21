# frozen_string_literal: true

require 'relaton/itu/data_fetcher'

FileUtils.rm_rf 'data'
FileUtils.rm Dir.glob('index*')

Relaton::Itu::DataFetcher.fetch
