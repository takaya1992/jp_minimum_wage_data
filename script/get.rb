require 'date'
require 'json'
require 'mechanize'
require 'jp_prefecture'
require 'wareki'

SITE_URL = 'http://www.mhlw.go.jp/stf/seisakunitsuite/bunya/koyou_roudou/roudoukijun/minimumichiran/'
TR_COUNT = 49  # 47都道府県 + タイトル行 + フッター行
CALLBACK_FUNCTION_NAME = '$jpMinimumWageCallback'
SAVE_JSON_FILE = 'docs/minimum_wage.json'
SAVE_JSONP_FILE = 'docs/minimum_wage.jsonp'

agent = Mechanize.new
page = agent.get(SITE_URL)

# HTML内にtableが1つだけあり、行(tr)が49つ(47都道府県 + タイトル行 + フッター行)あることを前提とする
# 49行ではなかった場合はエラーとして終了
tr_list = page.search('table tr')
exit false unless tr_list.length === TR_COUNT

# 先頭行はタイトル行とし、読み捨てる
tr_list.shift
# 最終行はフッター行とし、読み捨てる
tr_list.pop

minimum_wages = []
tr_list.each do |tr|
  td_list = tr.search('td')
  fuzzy_pref_name = td_list[0].inner_text
  fuzzy_wage = td_list[1].inner_text
  fuzzy_effective_date = td_list[3].inner_text
  prefecture = JpPrefecture::Prefecture.find(name: fuzzy_pref_name.gsub(/(\s|　)+/, ''))
  wage = fuzzy_wage.gsub(/(\s|　|,)+/, '').to_i
  effective_date = Date.parse(fuzzy_effective_date)
  minimum_wages.push({
    prefecture_name: prefecture.name,
    prefecture_code: prefecture.code,
    wage:            wage,
    effective_date:  effective_date.strftime('%F')
  })
end

json_data = JSON.generate({
  minimum_wages: minimum_wages,
  last_checked_at: DateTime.now.strftime('%FT%T%:z')
})
File.open(SAVE_JSON_FILE, 'w') do |file|
  file.puts json_data
end

File.open(SAVE_JSONP_FILE, 'w') do |file|
  file.puts "#{CALLBACK_FUNCTION_NAME}(#{json_data});"
end
