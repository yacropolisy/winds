class HomeController < ApplicationController
  def index
    @msg = 'hello!'

    require 'open-uri'
    require 'nokogiri'
    require 'robotex'
    robotex = Robotex.new

    # スクレイピング先のURL
    url = 'http://6243.teacup.com/wind12/bbs'
    p robotex.allowed?(url)

    charset = nil
    html = open(url) do |f|
      charset = f.charset # 文字種別を取得
      f.read # htmlを読み込んで変数htmlに渡す
    end
    # htmlをパース(解析)してオブジェクトを作成
    doc = Nokogiri::HTML.parse(html, nil, charset)
    p doc.title
    titles = []
    authors = []
    createds = []
    articles = []

    doc.css('.Kiji_Title').each do |title|
      titles.push(title.text)
    end
    @titles = titles

    doc.css('.Kiji_Author').each do |author|
      authors.push(author.text)
    end
    @authors = authors

    doc.css('.Kiji_Created').each do |created|
      createds.push(created.text)
    end
    @createds = createds

    doc.css('.Kiji_Article').each do |article|
      articles.push(article.text)
    end
    @articles = articles
  end
end
