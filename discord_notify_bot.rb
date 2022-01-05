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

mention_mappings = {
  'ujihisa' => '<@349891868273672194>',
  'お豆腐ニキ' => '<@312616968882618368>',
  'pankona' => '<@372183319372103680>',
  'あさり食堂' => '<@630782140224765952>',
  'tattotatto0806' => '<@761750299118665728>',
  'yshr446' => '<@731154668033409046>',
}

discord('Server restarted')

current_players = []

IO.popen('tail -f /7-days-to-die/output_log.txt') do |io|
  loop do
    line = io.readline.chomp
    case line
    when %r(^[^ ]+ [^ ]+ INF RequestToEnterGame: [^/]+/(.+)$)
      # 2021-12-26T03:34:56 72.400 INF RequestToEnterGame: EOS_0002831795af4125b164741191188cab/ujihisa
      discord("#{$1} is trying to join")
    when %r(^[^ ]+ [^ ]+ INF GMSG: Player '(.+)' joined the game$)
      # 2021-12-26T03:35:40 115.999 INF GMSG: Player 'ujihisa' joined the game
      current_players << "#{$1}"
      discord("#{$1} joined the game. (Current players: #{current_players.join(', ')})")
    when %r(^[^ ]+ [^ ]+ INF GMSG: Player '(.+)' left the game$)
      # 2021-12-26T03:35:46 121.808 INF GMSG: Player 'ujihisa' left the game
      current_players.delete("#{$1}")
      discord("#{$1} left the game. (Current players: #{current_players.join(', ')})")
    when %r(^[^ ]+ [^ ]+ INF GMSG: Player '(.+)' died$)
      # 2021-12-27T15:14:33 127013.793 INF GMSG: Player 'ujihisa' died
      discord("#{$1} died")
    when %r(^[^ ]+ [^ ]+ INF Chat \([^\)]+\): '(.+)': (.*)$)
      # 2021-12-27T16:42:13 132273.809 INF Chat (from 'Steam_76561198145251396', entity id '177', to 'Global'): 'pankona': ~A~J
      (msg, who) = [$1, $2]
      case msg
      when /^!here\b/
        targets = mention_mappings.reject {|k, _| current_players.include?(k) }.values.shuffle.join(' ')
        discord("#{targets} いま盛り上がってます。レッツ参加!")
      when /^ .*/
        discord("#{who}「#{msg}」")
      end
    when %r(^[^ ]+ [^ ]+ INF (BloodMoon starting for day .*)$)
      # 2021-12-29T07:32:37 96581.661 INF BloodMoon starting for day 7
      discord("#{$1}")
    end
  end
end
