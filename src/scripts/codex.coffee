# Description:
#   Utility commands for Codexbot 
#
# Commands:
#   hubot newmsg <foo> - Reply back with <text>

module.exports = (robot) ->
  robot.respond /NEWMSG (.*)$/i, (msg) ->
    robot.ddp_call "newMessage", [
      nick: "codexbot"
      body: "synthesized " + msg.match[1]
    ]
