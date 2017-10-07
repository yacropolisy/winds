class HomeController < ApplicationController
  def index
    @msg = 'hello!'

    require 'open-uri'
    require 'nokogiri'
    # スクレイピング先のURL
    url = 'http://weather-gpv.info/'
    charset = nil
    html = open(url) do |f|
      charset = f.charset # 文字種別を取得
      f.read # htmlを読み込んで変数htmlに渡す
    end
   # htmlをパース(解析)してオブジェクトを作成
   doc = Nokogiri::HTML.parse(html, nil, charset)
   @title = doc.title
   @img = doc.xpath('html/frameset/frame/html/body/div/span/img')
  end
end
