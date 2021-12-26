require 'uri'
require 'net/http'
require 'json'

def discord(msg)
  Net::HTTP.post(
    URI.parse(ENV.fetch('DISCORD_WEBHOOK_URL')),
    { content: msg.to_s }.to_json,
    { 'Content-Type' => 'application/json' },
  )
end

discord('Server restarted')

IO.popen('tail -f /7-days-to-die/output_log.txt') do |io|
  loop do
    line = io.readline.chomp
    case line
    when %r(^[^ ]+ [^ ]+ INF RequestToEnterGame: [^/]+/(.+)$)
      # 2021-12-26T03:34:56 72.400 INF RequestToEnterGame: EOS_0002831795af4125b164741191188cab/ujihisa
      discord("#{$1} is trying to join")
    when %r(^[^ ]+ [^ ]+ INF GMSG: Player '(.+)' joined the game$)
      # 2021-12-26T03:35:40 115.999 INF GMSG: Player 'ujihisa' joined the game
      discord("#{$1} joined the game")
    when %r(^[^ ]+ [^ ]+ INF GMSG: Player '(.+)' left the game$)
      # 2021-12-26T03:35:46 121.808 INF GMSG: Player 'ujihisa' left the game
      discord("#{$1} left the game")
    end
  end
end
