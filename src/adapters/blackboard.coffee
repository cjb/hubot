Robot                                   = require '../robot'
Adapter                                 = require '../adapter'
{TextMessage,EnterMessage,LeaveMessage} = require '../message'

DDPClient = require("/home/codex/node-ddp-client/lib/ddp-client")

class Blackboardbot extends Adapter
  run: ->
    self = @
    @robot.name = ""
    @ready = false
    @subscription = false

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
      self.ddpclient.call "newNick", ["name": "codexbot", "tags": [name: "gravatar", value: "codex@printf.net"]]
      keepalive()
      self.emit 'connected'

    update_cb = (data) ->
      if @ready
        console.log "in update_cb"
        if data.fields and data.fields.nick and data.fields.body
          console.log "incoming: #{data.fields.nick}, #{data.fields.body}"
        if data.fields and data.fields.nick isnt "codexbot" and data.fields.system is false and data.fields.nick isnt ""
          console.log "incoming2: #{data.fields.nick}, #{data.fields.body}"
          self.receive new TextMessage data.fields.nick, data.fields.body

    # Connect to Meteor
    self.ddpclient = new DDPClient(host: "localhost", port: 3000)
    @robot.ddpclient = self.ddpclient
    self.ddpclient.connect ->
      console.log "connected!"
      if not @subscription
        self.ddpclient.subscribe "messages-in-range", ["general/0", new Date().getTime(), 0], initial_cb, update_cb, "messages"
        @subscription = true
      @interval = setInterval(keepalive, 30000)

  send: (user, strings...) ->
    self = @
    console.log "#{user}: #{strings}"
    self.ddpclient.call "newMessage", [
      nick: "codexbot"
      body: "#{user}: #{strings}"
    ]

  priv: (user, strings...) ->
    self = @
    console.log "priv: #{user}: #{strings}"
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
