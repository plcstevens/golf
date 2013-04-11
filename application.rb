require "goliath"
require "em-http"
require "em-synchrony/em-http"
require "erb"
require "json"

class Hello < Goliath::API
  API = "http://www.masters.com/en_US/xml/gen/homeScores/homeScores.json"

  def response(env)
    [status, headers, body]
  end

  private
  def status
    200
  end

  def headers
    { "Content-Type" => "text/html" }
  end

  def body
    scores = JSON.parse(EM::HttpRequest.new(API).get.response)
    players = scores["homeScores"]["player"]

    ERB.new(File.read("view.html.erb")).result(binding)
  end

  def position(player)
    pos = case player["pos"]
      when ""
        "N/A"
      when @prev
        "-"
      else
        player["pos"]
      end

    @prev = player["pos"]

    pos.gsub("T", "")
  end

  def completion(player)
    holes = case player["thru"]
      when "F"
        18
      when nil
        0
      else
        player["thru"]
      end

    (holes.to_f / 18 * 100).round
  end

  def background(player)
    number = player["pos"].gsub("T", "").to_i
    number = 93 if number.zero?

    green = (92 - number + 1).to_f / 92 * 255
    red = 255 - green
    
    "rgb(#{red.round}, #{green.round}, 0)"
  end
end
