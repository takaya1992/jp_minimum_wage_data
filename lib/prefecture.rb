class Prefecture

  def self.convert(prefecture_name)
    striped_prefecture_name = prefecture_name.gsub(/(\s|　)+/, '')
    return striped_prefecture_name        if striped_prefecture_name === '北海道'
    return striped_prefecture_name + "都" if striped_prefecture_name === '東京'
    return striped_prefecture_name + "府" if striped_prefecture_name =~ /大阪|京都/
    return striped_prefecture_name + "県"
  end

end
