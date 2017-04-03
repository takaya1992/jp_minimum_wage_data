require 'mechanize'
require 'json'
require './lib/prefecture'

SITE_URL = 'http://www.mhlw.go.jp/stf/seisakunitsuite/bunya/koyou_roudou/roudoukijun/minimumichiran/'
TR_COUNT = 49  # 47都道府県 + タイトル行 + フッター行
SAVE_JSON_FILE = 'docs/minimum_wage.json'
SAVE_JSONP_FILE = 'docs/minimum_wage.jsonp'

agent = Mechanize.new
page = agent.get(SITE_URL)

# HTML内にtableが1つだけあり、行(tr)が49つ(47都道府県 + タイトル行 + フッター行)あることを前提とする
# 49行ではなかった場合はエラーとして終了
tr_list = page.search('table tr')
exit false unless tr_list.length === 49

minimum_wages = {}

# 先頭行はタイトル行とし、読み捨てる
tr_list.shift
# 最終行はフッター行とし、読み捨てる
tr_list.pop

tr_list.each do |tr|
  td_list = tr.search('td')
  prefecture_name = Prefecture.convert(td_list.first.inner_text)
  wage = td_list[1].inner_text.gsub(/(\s|　|,)+/, '').to_i
  minimum_wages[prefecture_name] = wage
end

json_data = JSON.generate(minimum_wages)
File.open(SAVE_JSON_FILE, 'w') do |file|
  file.puts json_data
end

File.open(SAVE_JSONP_FILE, 'w') do |file|
  file.puts "callback(#{json_data});"
end
