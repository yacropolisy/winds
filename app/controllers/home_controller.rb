require 'open-uri'
require 'nokogiri'
require 'robotex'
require "twitter"



class HomeController < ApplicationController
  def index
    survey
  end

  def main
    @posts = Post.all.order('date DESC')
    survey
  end

  def survey
    Thread.start do
      #スクレイピング
      p 'scraping'

      robotex = Robotex.new
      # スクレイピング先のURL
      url = 'http://6243.teacup.com/wind12/bbs'
      if robotex.allowed?(url)
        charset = nil
        html = open(url) do |f|
          charset = f.charset # 文字種別を取得
          f.read # htmlを読み込んで変数htmlに渡す
        end
        # htmlをパース(解析)してオブジェクトを作成
        doc = Nokogiri::HTML.parse(html, nil, charset)
        p doc.title

        hps = []
        titles = []
        authors = []
        createds = []
        articles = []
        colors = []

        doc.css('.Kiji_Title').each do |title|
          hps.push(doc.title)
          titles.push(title.text)
          colors.push('background-color:#be7bd4;')
        end

        doc.css('.Kiji_Author').each do |author|
          authors.push(author.text)
        end

        doc.css('.Kiji_Created').each do |created|
          createds.push(convert_date(created.text))
        end

        doc.css('.Kiji_Article').each do |article|
          articles.push(article.text)
        end
      end

      #twitter API
      p "twitter api"
      #初期設定
      client = Twitter::REST::Client.new do |config|
        config.consumer_key = "tMU83Elbd784Ed3oPPDn54bW4"
        config.consumer_secret = "Ko5VeAy4rtuza6vSqvbZ3VeBe4BJLA1Avr9vCqB7dcqyPQMAZp"
        config.access_token = "1315936560-UihYbqt29N5xdLsu2zFJHM3xontjX7ivTKgvwD2"
        config.access_token_secret = "hhlmMpTwL8rVx0smf7Ucr98vZyCbjscdBDz0iAgOl3EDI"
      end
      # 特定ユーザのtimeline取得
      account = client.user("doshisha3551").screen_name
      username = client.user("doshisha3551").name
      client.user_timeline("doshisha3551").each do |timeline|
        createds.push(client.status(timeline.id).created_at.to_s)
        articles.push(client.status(timeline.id).text)
        hps.push(username + " twitter")
        titles.push(username)
        authors.push(account)
        colors.push('background-color:#2da1e0;')
      end
      #dbに登録
      p 'create posts'
      titles.size.times do |i|
        flag = 1
        Post.all.each do |p|
          if p.date == createds[i]
            if p.hp == hps[i]
              flag = 0
              break
            end
          end
        end
        if flag == 1
          Post.create!(hp: hps[i], title: titles[i], author: authors[i], date: createds[i], article: articles[i], color: colors[i] )
          p 'created'
        end
      end
      #古いpostsの削除
      p 'delete posts'
      a_month = 60 * 60 * 24 * 30
      expiredate = Time.now - a_month

      Post.all.each do |p|
        if p.date < expiredate
          p.destroy
        end
      end
    end
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
