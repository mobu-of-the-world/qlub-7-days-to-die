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

current_players = []

IO.popen('tail -f /7-days-to-die/output_log.txt') do |io|
  loop do
    line = io.readline.chomp
    case line
    when %r(^[^ ]+ [^ ]+ INF RequestToEnterGame: [^/]+/(.+)$)
      # 2021-12-26T03:34:56 72.400 INF RequestToEnterGame: EOS_0002831795af4125b164741191188cab/ujihisa
      discord("@#{$1} is trying to join")
    when %r(^[^ ]+ [^ ]+ INF GMSG: Player '(.+)' joined the game$)
      # 2021-12-26T03:35:40 115.999 INF GMSG: Player 'ujihisa' joined the game
      current_players << "@#{$1}"
      discord("@#{$1} joined the game. (Current players: #{current_players.join(', ')})")
    when %r(^[^ ]+ [^ ]+ INF GMSG: Player '(.+)' left the game$)
      # 2021-12-26T03:35:46 121.808 INF GMSG: Player 'ujihisa' left the game
      current_players.delete("@#{$1}")
      discord("@#{$1} left the game. (Current players: #{current_players.join(', ')})")
    when %r(^[^ ]+ [^ ]+ INF GMSG: Player '(.+)' died$)
      # 2021-12-27T15:14:33 127013.793 INF GMSG: Player 'ujihisa' died
      discord("@#{$1} died")
    when %r(^[^ ]+ [^ ]+ INF Chat \([^\)]+\): '(.+)': (.*)$)
      # 2021-12-27T16:42:13 132273.809 INF Chat (from 'Steam_76561198145251396', entity id '177', to 'Global'): 'pankona': ~A~J
      discord("@#{$1}「#{$2}」")
    end
  end
end
