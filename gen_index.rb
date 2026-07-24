# frozen_string_literal: true

# Regenerate the pubid-structured index-v2.yaml from the existing index-v1.yaml
# id->file rows, then zip it to index-v2.zip. Deterministic and offline: the
# data/*.yaml files and index-v1.* are left untouched — only the primary docid of
# each existing row is reparsed through pubid.
#
# Each id is kept only if it round-trips (from_hash(to_hash).to_hash == to_hash),
# the identical guard Relaton::Itu::DataFetcher#pubid applies. That is a strict
# subset of what the index loader's Relaton::Index::FileIO#id_supported? accepts,
# so producer and consumer agree and a non-round-tripping id can never poison the
# published index. ITU-R Questions
# and Handbooks now round-trip (pubid feat/itu-questions-handbooks); the handful
# of remaining skips are malformed/series-level ids that are not real documents.
#
# Usage: bundle exec ruby gen_index.rb
$stdout.sync = true
require "yaml"
require "zip"
require "relaton/itu/data_fetcher" # pulls in Relaton::Index + ::Pubid::Itu

SRC = "index-v1.yaml"
OUT = "index-v2.yaml"
ZIP = "index-v2.zip"

# Mirror Relaton::Itu::DataFetcher#pubid exactly. The strict round-trip is a subset
# of what the index loader's Index::FileIO#id_supported? accepts (the loader also
# short-circuits on a matching subtype and compares normalized hashes), so any id
# this guard keeps is guaranteed loadable — the index can never be poisoned.
def pubid(id)
  pid = ::Pubid::Itu.parse id
  hash = pid.to_hash
  return nil unless ::Pubid::Itu::Identifier.from_hash(hash).to_hash == hash

  pid
rescue StandardError
  nil
end

File.delete(OUT) if File.exist?(OUT)
index = Relaton::Index.find_or_create(:itu, file: OUT, pubid_class: ::Pubid::Itu::Identifier)

added = 0
skipped = []
YAML.load_file(SRC).each do |row|
  id = row[:id]     # index-v1 uses Ruby symbol keys (:id:, :file:)
  file = row[:file]
  if (pid = pubid(id))
    index.add_or_update pid, file
    added += 1
  else
    skipped << id
  end
end
index.save

# Rebuild the zip deterministically (single flat entry, matching index-v1.zip).
File.delete(ZIP) if File.exist?(ZIP)
Zip::File.open(ZIP, create: true) { |zip| zip.add(OUT, OUT) }

puts "index-v2.yaml: #{added} indexed, #{skipped.size} skipped"
puts "skipped (malformed/series-level, not modelled): #{skipped.inspect}" unless skipped.empty?
puts "index-v2.zip: #{File.size(ZIP)} bytes"
