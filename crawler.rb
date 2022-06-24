# frozen_string_literal: true

require 'English'
require 'yaml'
require 'json'
require 'mechanize'
require 'relaton_itu'

@files = []

# @param doc [Mechanize::Page]
# @return [Araay<RelatonBib::DocumentIdentifier>]
def fetch_docid(doc)
  # id = doc.at('//h3[.="Number"]/parent::td/following-sibling::td[2]').text # .match(/^[^\s\(]+/).to_s
  # %r{^(?<id1>[^\s\(\/]+(\/\d+)?)(\/(?<id2>\w+[^\s\(]+))?} =~ id
  id = doc.at('//div[@id="idDocSetPropertiesWebPart"]/h2').text.match(/^R-\w+-([^-]+(?:-\d{1,3})?)/)[1]
  [RelatonBib::DocumentIdentifier.new(type: 'ITU', id: "ITU-R #{id}", primary: true)]
  # docid << RelatonBib::DocumentIdentifier.new(type: 'ITU', id: id2) if id2
  # docid
end

# @param doc [Mechanize::Page]
# @return [Araay<RelatonBib::TypedTitleString>]
def fetch_title(doc)
  content = doc.at('//h3[.="Title"]/parent::td/following-sibling::td[2]').text
  [RelatonBib::TypedTitleString.new(type: 'main', content: content, language: 'en', script: 'Latn')]
end

# @param doc [Mechanize::Page]
# @return [Araay<RelatonBib::BibliographicDate>]
def fetch_date(doc)
  dates = []
  date = doc.at('//h3[.="Approval_Date"]/parent::td/following-sibling::td[2]',
                '//h3[.="Approval date"]/parent::td/following-sibling::td[2]',
                '//h3[.="Approval year"]/parent::td/following-sibling::td[2]')
  dates << parse_date(date.text, 'confirmed') if date

  date = doc.at('//h3[.="Version year"]/parent::td/following-sibling::td[2]')
  dates << parse_date(date.text, 'updated') if date
  date = doc.at('//div[@id="idDocSetPropertiesWebPart"]/h2').text.match(/(?<=-)[12]\d{3,5}/)
  dates << parse_date(date.to_s, 'published') if date
  dates
end

# @param date [String]
# @param type [String]
# @return [RelatonBib::BibliographicDate]
def parse_date(date, type)
  d = case date
      when /^\d{4}$/ then date
      when /(\d{4})(\d{2})/ then "#{$LAST_MATCH_INFO[1]}-#{$LAST_MATCH_INFO[2]}"
      when %r{(\d{2})\/(\d{2})\/(\d{4})} then "#{$LAST_MATCH_INFO[3]}-#{$LAST_MATCH_INFO[2]}-#{$LAST_MATCH_INFO[1]}"
      else date
      end
  RelatonBib::BibliographicDate.new(type: type, on: d)
end

# @param url [String]
# @param type [String]
# @param agent [Mechanize]
def parse_page(url, type, agent)
  doc = agent.get url
  bib = RelatonItu::ItuBibliographicItem.new(
    fetched: Date.today.to_s, docid: fetch_docid(doc), title: fetch_title(doc),
    abstract: fetch_abstract(doc), date: fetch_date(doc), language: ['en'],
    link: fetch_link(url), script: ['Latn'], docstatus: fetch_status(doc),
    type: 'standard', doctype: type
  )
  write_file bib
end

# @param url [String]
# @return [Array<RelatonBib::TypedUri>]
def fetch_link(url)
  [RelatonBib::TypedUri.new(type: 'src', content: url)]
end

# @param doc [Mechanize::Page]
# @return [Array<RelatonBib::FormattedString>]
def fetch_abstract(doc)
  doc.xpath('//h3[.="Observation"]/parent::td/following-sibling::td[2]').map do |a|
    c = a.text.strip
    RelatonBib::FormattedString.new content: c, language: 'en', script: 'Latn' unless c.empty?
  end.compact
end

# @param doc [Mechanize::Page]
# @return [RelatonBib::DocumentStatus, nil]
def fetch_status(doc)
  s = doc.at('//h3[.="Status"]/parent::td/following-sibling::td[2]')
  return unless s

  RelatonBib::DocumentStatus.new stage: s.text
end

# @param bib [RelatonItu::ItuBibliographicItem]
def write_file(bib)
  id = bib.docidentifier[0].id.gsub(/[\s.]/, '_')
  file = "data/#{id}.yaml"
  if @files.include? file
    warn "File #{file} exists."
  else
    @files << file
  end
  File.write file, bib.to_hash.to_yaml, encoding: 'UTF-8'
end

# @param agent [Mechanize]
# #param url [String]
# @param workers [RelatonBib::WorkersPool]
# @param type [String]
def json_index(agent, indexurl, workers, type)
  result = agent.post indexurl
  json = JSON.parse result.body
  json['Row'].each { |row| workers << [row['serverurl.progid'].sub(/^1/, ''), type, agent] }
  return unless json['NextHref']

  nexturl = indexurl.sub(/(Paged|FolderCTID)=.+/, json['NextHref'].match(/(?<=aspx\?).+/).to_s)
  json_index agent, nexturl, workers, type
end

# @param agent [Mechanize]
# #param url [String]
# @param workers [RelatonBib::WorkersPool]
# @param type [String]
def html_index(agent, url, workers, type)
  resp = agent.get url
  result = Nokogiri::HTML resp.body
  result.xpath('//table//table/tr[position() > 1]').each do |hit|
    url = hit.at('td/a')[:onclick].match(%r{https:\/\/[^']+}).to_s
    workers << [url, type, agent]
  end
end

agent = Mechanize.new
workers = RelatonBib::WorkersPool.new 10
# log_file = 'parse.log'
# File.delete log_file if File.exist? log_file
# log = File.new log_file, 'a'
workers.worker do |row|
  parse_page(*row)
rescue => e # rubocop:disable Style/RescueStandardError
  warn e.message
  warn e.backtrace
end
t1 = Time.now
puts "Started at: #{t1}"

url = 'https://extranet.itu.int/brdocsearch/_layouts/15/inplview.aspx?'\
'List=%7B0661B581-2413-4E84-BAB2-77E6DB27AF7F%7D&'\
'View=%7BC81191DD-48C4-4881-9CB7-FB61C683FE98%7D&'\
'ViewCount=123&'\
'IsXslView=TRUE&'\
'IsCSR=TRUE&'\
'ListViewPageUrl=https%3A%2F%2Fextranet.itu.int%2Fbrdocsearch%2FR-REC%2FForms%2Ffolders_inforce.aspx&'\
'FolderCTID=0x012001'
json_index agent, url, workers, 'recommendation'

url = 'https://extranet.itu.int/brdocsearch/R-QUE/Forms/folders_inforce.aspx'
html_index agent, url, workers, 'question'

url = 'https://extranet.itu.int/brdocsearch/_layouts/15/inplview.aspx?'\
'List=%7B82E4A13D-C7F3-4844-9E8A-2463C4B7784F%7D&'\
'View=%7B94CC1561-E4AC-4317-B402-AA0AADD7F414%7D&'\
'ViewCount=407&'\
'IsXslView=TRUE&'\
'IsCSR=TRUE&'\
'ListViewPageUrl=https%3A%2F%2Fextranet.itu.int%2Fbrdocsearch%2FR-REP%2FForms%2FFolders%2520InForce.aspx&'\
'FolderCTID=0x012001'
json_index agent, url, workers, 'technical-report'

url = 'https://extranet.itu.int/brdocsearch/R-HDB/Forms/Folders%20InForce.aspx'
html_index agent, url, workers, 'handbook'

url = 'https://extranet.itu.int/brdocsearch/R-RES/Forms/Folders%20InForce.aspx'
html_index agent, url, workers, 'resolution'

workers.end
workers.result
# log.close

t2 = Time.now
puts "Stopped at: #{t2}"
puts "Done in: #{(t2 - t1).round} sec."
