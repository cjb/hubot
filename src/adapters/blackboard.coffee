Robot                                   = require '../robot'
Adapter                                 = require '../adapter'
{TextMessage,EnterMessage,LeaveMessage} = require '../message'

DDPClient = require("/srv/node-ddp-client/lib/ddp-client")

class Blackboardbot extends Adapter
  run: ->
    self = @
    @robot.name = ""
    @ready = false

    keepalive = ->
      self.ddpclient.call "setPresence", [
        nick: "codexbot"
        room_name: "general/0"
        present: true
        foreground: true
      ]

    initial_cb = ->
      @ready = true
      self.ddpclient.call "deleteNick", ["name": "codexbot", "tags": {}]
      self.ddpclient.call "newNick", ["name": "codexbot", "tags": {gravatar: "codex@printf.net"}]
      keepalive()
      self.emit 'connected'

    update_cb = (data) ->
      if @ready
        if data.set and data.set.nick isnt "codexbot" and data.set.system is false and data.set.nick isnt ""
          self.receive new TextMessage data.set.nick, data.set.body

    # Connect to Meteor
    self.ddpclient = new DDPClient(host: "localhost", port: 3000)
    @robot.ddpclient = self.ddpclient
    self.ddpclient.connect ->
      console.log "connected!"
      self.ddpclient.subscribe "recent-messages", ["codexbot", "general/0"], initial_cb, update_cb, "messages"
      @interval = setInterval(keepalive, 30000)

  send: (user, strings...) ->
    self = @
    self.ddpclient.call "newMessage", [
      nick: "codexbot"
      body: "#{user}: #{strings}"
    ]

  priv: (user, strings...) ->
    self = @
    self.ddpclient.call "newMessage", [
      nick: "codexbot"
      to: "#{user}"
      body: "#{user}: #{strings}"
    ]

  reply: (user, strings...) ->
    self = @
    @send user, strings

  ddp_call: (method, args) ->
    self = @
    self.ddpclient.call method, args

exports.use = (robot) ->
  new Blackboardbot robot
