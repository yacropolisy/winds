class HomeController < ApplicationController
  def index
    @msg = 'hello!'
    postdate = '20170712000001'
    flag = 1
    Post.all.each do |p|
      if p.date == postdate
        @msg = 'kuku'
        if p.hp == 'kyodai'
          @msg = 'haha'
          flag = 0
          break
        end
      end
    end
    if flag == 1
      Post.create!(hp: 'kyodai', title: 'hogehoge', author: 'yyamada', date: postdate, article: 'hugehuge\nhogehoge' )
      @msg = 'mumu'
    end

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

    titles.size.times do |i|
      flag = 1
      Post.all.each do |p|
        if p.date == convert_date(createds[i])
          if p.hp == doc.title
            flag = 0
            break
          end
        end
      end
      if flag == 1
        Post.create!(hp: doc.title, title: titles[i], author: authors[i], date: convert_date(createds[i]), article: articles[i] )
      end
    end

  end

  def board
    @posts = Post.all.order('date DESC')
  end

  def convert_date(text)
    y_i = text.index('年')
    y = text.slice((y_i-4)..(y_i-1))

    m_i = text.index('月')
    m = text.slice((m_i-2)..(m_i-1))
    if m.to_i.to_s != m
      m[0] = '0'
    end
    m

    d_i = text.index('日(')
    d = text.slice((d_i-2)..(d_i-1))
    if d.to_i.to_s != d
      d[0] = '0'
    end
    d

    h_i = text.index('時')
    h = text.slice((h_i-2)..(h_i-1))
    if h.to_i.to_s != h
      h[0] = '0'
    end

    mi_i = text.index('分')
    mi = text.slice((mi_i-2)..(mi_i-1))
    if mi.to_i.to_s != mi
      mi[0] = '0'
    end

    s_i = text.index('秒')
    s = text.slice((s_i-2)..(s_i-1))
    if s.to_i.to_s != s
      s[0] = '0'
    end
    ret = y + m + d + h + mi + s
    return ret
  end

end
