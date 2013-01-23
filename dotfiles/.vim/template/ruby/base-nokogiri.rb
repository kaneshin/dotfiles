require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'kconv'

uri = '{{_input_:URI}}'
html = open(uri).read
doc = Nokogiri::HTML(html.toutf8, nil, 'utf-8')
p doc

doc.search('a').each do |link|
	p link['href']
end
{{_cursor_}}
