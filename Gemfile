# frozen_string_literal: true

source "https://rubygems.org"

# index-v2 is a pubid-structured index (rows carry `_type: pubid:itu:*`). It must
# be produced by the SAME relaton/pubid the released Relaton::Itu flavor consumes:
#   - relaton monorepo (main) — the ITU index-v2 flavor.
#   - pubid (main) — ITU-R Question/Handbook identifier parsing, the flat `to_hash`
#     the index rows use, and the `#number` delegation that lets Relaton::Index
#     sort the index by document number.
gem "relaton", git: "https://github.com/relaton/relaton.git", branch: "main"
gem "pubid", git: "https://github.com/metanorma/pubid.git", branch: "main"

# index generation + verification. rubyzip (for index-v2.zip) comes from
# relaton, which sets its version. Do not pin it here: a pin blocks
# `bundle install` when relaton bumps it (the ~> 2.3 pin did exactly that).
gem "rspec", "~> 3.0"
