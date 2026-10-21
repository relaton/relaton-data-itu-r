# frozen_string_literal: true

require 'relaton/itu/data_fetcher'

# Incremental crawl: keep data/ and let the fetcher skip byte-identical
# records and prune stale ones (relaton#328).
Relaton::Itu::DataFetcher.fetch(prune: true)
