# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

flip = require 'flip'

module.exports = (robot) ->

  robot.respond /http cat (.*)/i, (res) ->
    res.send "https://http.cat/" + res.match[1];

  robot.respond /http dog (.*)/i, (res) ->
    res.send "http://httpstatusdogs.com/" + res.match[1];

  robot.hear /badger/i, (res) ->
    res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"

  robot.hear /(.*) ?\+\+/i, (res) ->
    key = res.match[1].replace(/@/g, "")
    karma = robot.brain.get('karma-' + key) || 0;
    robot.brain.set('karma-' + key, karma + 1)
    res.send key + ' has ' + (karma + 1) + ' points.';

  robot.hear /(.*) ?\-\-/i, (res) ->
    key = res.match[1].replace(/@/g, "")
    karma = robot.brain.get('karma-' + key) || 0;
    robot.brain.set('karma-' + key, karma - 1)
    res.send key + ' has ' + (karma - 1) + ' points.';

  robot.respond /score (.*)/i, (res) ->
    karma = robot.brain.get('karma-' + res.match[1]) || 0;
    console.log(karma);
    res.send res.match[1] + ' has ' + (karma) + ' points.';
  
  robot.respond /open the (.*) doors/i, (res) ->
    doorType = res.match[1]
    if doorType is "pod bay"
      res.reply "I'm afraid I can't let you do that."
    else
      res.reply "Opening #{doorType} doors"
  
  robot.hear /I like pie/i, (res) ->
    res.emote "makes a freshly baked pie"
  
  lulz = ['lol', 'rofl', 'lmao']
  
  robot.respond /lulz/i, (res) ->
    res.send res.random lulz
  
  robot.topic (res) ->
    res.send "#{res.message.text}? That's a Paddlin'"
  
  
  enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
  leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
  
  robot.enter (res) ->
    res.send res.random enterReplies
  robot.leave (res) ->
    res.send res.random leaveReplies
  
  answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  
  robot.respond /what is the answer to the ultimate question of life/, (res) ->
    unless answer?
      res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
      return
    res.send "#{answer}, but what is the question?"
  
  robot.respond /you are a little slow/, (res) ->
    setTimeout () ->
      res.send "Who you calling 'slow'?"
    , 60 * 1000
  
  annoyIntervalId = null
  
  robot.respond /annoy me/, (res) ->
    if annoyIntervalId
      res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
      return
  
    res.send "Hey, want to hear the most annoying sound in the world?"
    annoyIntervalId = setInterval () ->
      res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
    , 1000
  
  robot.respond /unannoy me/, (res) ->
    if annoyIntervalId
      res.send "GUYS, GUYS, GUYS!"
      clearInterval(annoyIntervalId)
      annoyIntervalId = null
    else
      res.send "Not annoying you right now, am I?"
  
  
  robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
    room   = req.params.room
    data   = JSON.parse req.body.payload
    secret = data.secret
  
    robot.messageRoom room, "I have a secret: #{secret}"
  
    res.send 'OK'
  
  robot.error (err, res) ->
    robot.logger.error "DOES NOT COMPUTE"
  
    if res?
      res.reply "DOES NOT COMPUTE"
  
  robot.respond /have a soda/i, (res) ->
    # Get number of sodas had (coerced to a number).
    sodasHad = robot.brain.get('totalSodas') * 1 or 0
  
    if sodasHad > 4
      res.reply "I'm too fizzy.."
  
    else
      res.reply 'Sure!'
  
      robot.brain.set 'totalSodas', sodasHad+1
  
  robot.respond /sleep it off/i, (res) ->
    robot.brain.set 'totalSodas', 0
    res.reply 'zzzzz'

  robot.respond /(rage )?flip( .*)?$/i, (msg) ->
    if msg.match[1] == 'rage '
      guy = '(ノಠ益ಠ)ノ彡'
    else
      guy = '(╯°□°）╯︵'

    toFlip = (msg.match[2] || '').trim()

    if toFlip == 'me'
      toFlip = msg.message.user.name

    if toFlip == ''
      flipped = '┻━┻'
    else
      flipped = flip(toFlip)

    msg.send "#{guy} #{flipped}"


  robot.respond /unflip( .*)?$/i, (msg) ->
    toUnflip = (msg.match[1] || '').trim()

    if toUnflip == 'me'
      unflipped = msg.message.user.name
    else if toUnflip == ''
      unflipped = '┬──┬'
    else
      unflipped = toUnflip

    msg.send "#{unflipped} ノ( º _ ºノ)"

  robot.hear /decisions\[(.*)\] \+\= (.*)/i, (msg) ->
    key = msg.match[1]
    value = msg.match[2]
    existing_value = robot.brain.get key

    output = null
    if existing_value == null
      output = value
      robot.brain.set key, value + "\<\!\>"
    else
      output = existing_value + "\n" + value
      robot.brain.set key, existing_value + "\<\!\>" + value

    msg.send "Your decision has been added."

  robot.hear /fetch decision (.*)/i, (msg) ->
    key = msg.match[1]

    if (robot.brain.get key) == null
      msg.send "There are no decisions regarding *" + key + "*"
    else
      msg.send "*" + key + "*"
      msg.send (robot.brain.get key).split("\<\!\>").join("\n")
    

