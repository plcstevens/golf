require 'tilt'
require 'goliath'
require 'em-http'
require 'em-synchrony/em-http'
require 'goliath/rack/templates'
require 'json'

class Hello < Goliath::API
  use Goliath::Rack::Render                 # auto-negotiate response format
  use Goliath::Rack::Heartbeat              # respond to /status with 200, OK (monitoring, etc)

  include Goliath::Rack::Templates          # render templated files from ./views

  use(Rack::Static,                         # render static files from ./public
      root: Goliath::Application.app_path("public"),
      urls: ["/favicon.ico", '/stylesheets', '/javascripts', '/images'])

  # API to read data from
  API = "http://www.masters.com/en_US/xml/gen/scores/scores.low.json"

  def response(env)
    case env['PATH_INFO']
      when /.+\.json/ then
        [status, { "Content-Type" => "application/json"}, json]
      else
        [status, headers, body]
    end

  end

  private
  def status
    200
  end

  def headers
    { "Content-Type" => "text/html" }
  end

  def json
    EM::HttpRequest.new(API).get.response
  end

  def body
    response = JSON.parse(json)
    players       = response["data"]["player"]

    haml(
        :index,
         locals: {
             players: players
         }
    )
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

  def name(player)
    "#{player['first']} #{player['last']}"
  end
end
