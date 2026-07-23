# frozen_string_literal: true

source "https://rubygems.org"

# index-v2 is a pubid-structured index (rows carry `_type: pubid:itu:*`). It must
# be produced by the SAME relaton/pubid the released Relaton::Itu flavor consumes:
#   - relaton monorepo, branch feat/itu-index-v2 — the ITU index-v2 flavor.
#   - pubid, branch feat/itu-questions-handbooks — adds ITU-R Question/Handbook
#     identifier parsing + the flat `to_hash` the index rows use.
#
# LOCAL PATH PINS (generation only): neither feature branch is pushed to origin
# yet, so these point at the local worktrees. Before committing for CI, swap to
# git branch pins, then to `main` once both branches merge upstream:
#   gem "relaton", git: "https://github.com/relaton/relaton.git", branch: "feat/itu-index-v2"  # -> "main"
#   gem "pubid",   git: "https://github.com/metanorma/pubid.git", branch: "feat/itu-questions-handbooks"  # -> "main"
gem "relaton", path: "/work/relaton/relaton/.claude/worktrees/feat/itu-index-v2"
gem "pubid",   path: "/work/metanorma/pubid/.claude/worktrees/feat/itu-questions-handbooks"

# index generation + verification
gem "rspec", "~> 3.0"
gem "rubyzip", "~> 2.3"
