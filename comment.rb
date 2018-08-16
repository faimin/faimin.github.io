username = "faimin" # GitHub 用户名
token = "0f8d6db7a1528e949b2b55fb925a7eeaf84b5b30"  # GitHub Token
repo_name = "faimin.github.io" # 存放 issues
kind = "Gitalk" # "Gitalk" or "gitment"
urls = ["https://faimin.github.io/2018/08/13/%E8%A7%A3%E8%AF%BBReactiveCocoa%E4%B8%AD%E7%9A%84%E9%83%A8%E5%88%86%E5%87%BD%E6%95%B0/"] # 需要初始化文章的数组

require 'open-uri'
require 'faraday'
require 'active_support'
require 'active_support/core_ext'

conn = Faraday.new(:url => "https://api.github.com/repos/#{username}/#{repo_name}/issues") do |conn|
  conn.basic_auth(username, token)
  conn.adapter  Faraday.default_adapter
end

urls.each_with_index do |url, index|
  title = open(url).read.scan(/<title>(.*?)<\/title>/).first.first.force_encoding('UTF-8')
  response = conn.post do |req|
    req.body = { body: url, labels: [kind, url], title: title }.to_json
  end
  puts response.body
  sleep 15 if index % 20 == 0
end