# Description:
#   Utility commands for Codexbot
#
# Commands:
#   hubot bot: The answer to <puzzle> is <answer>
#   hubot bot: Call in <answer> for puzzle>
#   hubot bot: Delete the answer to <puzzle>
#   hubot bot: <puzzle> is a new puzzle in round <round>
#   hubot bot: Delete puzzle <puzzle>
#   hubot bot: <round> is a new round in group <group>
#   hubot bot: Delete round <name>
#   hubot bot: <roundgroup> is a new round group
#   hubot bot: Delete round group <roundgroup>

module.exports = (robot) ->

## ANSWERS

# setAnswer
  robot.respond /bot: The answer to (.*?) is (.*)$/i, (msg) ->
    robot.ddpclient.call "getByName", [
      name: msg.match[1]
      optional_type: "puzzles"
    ], (err, puzzle) ->
      if err or not puzzle
        robot.ddpclient.call "newMessage", [
          nick: "codexbot",
          body: "I can't find a puzzle called #{msg.match[1]}."
        ]
        return
      else
        robot.ddpclient.call "setAnswer", [
          puzzle: puzzle.object._id
          answer: msg.match[2]
          who: "codexbot"
        ], (err, res) ->
          if err or not res
            console.log err, res
          else
            puzzle = msg.match[1]
            answer = msg.match[2]
            solution_banter = ["Huzzah!",
                               "Yay!",
                               "Pterrific!",
                               "Who'd have thought?",
                               "#{answer}?  Really?  Whoa.",
                               "Rock on!",
                               "#{puzzle} bites the dust!",
                               "#{puzzle}, meet #{answer}.  We rock!",
                              ]
            
            robot.ddpclient.call "newMessage", [
              nick: "codexbot",
              body: solution_banter[Math.floor(Math.random()*solution_banter.length)]
            ]

  # newCallIn
  robot.respond /bot: Call in (.*?) for (.*)$/i, (msg) ->
    answer = msg.match[1]
    name = msg.match[2]
    robot.ddpclient.call "getByName", [
      name: name
      optional_type: "puzzles"
    ], (err, puzzle) ->
      if err or not puzzle
        console.log err, puzzle
        return
      else
        robot.ddpclient.call "newCallIn", [
          puzzle: puzzle.object._id
          answer: answer
          who: "codexbot"
          name: name + answer
        ], (err, res) ->
          if err or not res
            console.log err, res
          else
            robot.ddpclient.call "newMessage", [
              nick: "codexbot",
              body: "Okay, #{answer} for #{puzzle.object.name} added to call-in list!"
            ]

# deleteAnswer
  robot.respond /bot: Delete the answer to (.*)$/i, (msg) ->
    robot.ddpclient.call "getByName", [
      name: msg.match[1]
      optional_type: "puzzles"
    ], (err, puzzle) ->
      if err or not puzzle
        robot.ddpclient.call "newMessage", [
          nick: "codexbot",
          body: "I can't find a puzzle called #{msg.match[1]}."
        ]
        return
      else
        robot.ddpclient.call "deleteAnswer", [
          puzzle: puzzle.object._id
          who: "codexbot"
        ], (err, res) ->
          if err or not res
            console.log err, res
          else
            robot.ddpclient.call "newMessage", [
              nick: "codexbot",
              body: "Okay, I deleted the answer to #{msg.match[1]}."
            ]

## PUZZLES

# newPuzzle
  robot.respond /bot: (.*?) is a new puzzle in round (.*)$/i, (msg) ->
    robot.ddpclient.call "getByName", [
      name: msg.match[2]
      optional_type: "rounds"
    ], (err, round) ->
      if err or not round
        robot.ddpclient.call "newMessage", [
          nick: "codexbot",
          body: "I can't find a round called #{msg.match[2]}."
        ]
        return
      else
        robot.ddpclient.call "newPuzzle", [
          name: msg.match[1]
          who: "codexbot"
        ], (err, puzzle) ->
          if err or not puzzle
            robot.ddpclient.call "newMessage", [
              nick: "codexbot",
              body: "I can't find a round called #{msg.match[2]}."
            ]   
            return
          else
            robot.ddpclient.call "addPuzzleToRound", [
              round: round.object._id
              puzzle: puzzle._id
              who: "codexbot"
            ], (err, res) ->
              if err or not res
                console.log err, res
              else
                robot.ddpclient.call "newMessage", [
                  nick: "codexbot",
                  body: "Okay, I added #{msg.match[1]} to #{msg.match[2]}."
                ]

# deletePuzzle
  robot.respond /bot: Delete puzzle (.*)$/i, (msg) ->
    robot.ddpclient.call "getByName", [
      name: msg.match[1]
      optional_type: "puzzles"
    ], (err, puzzle) ->
      if err or not puzzle
        robot.ddpclient.call "newMessage", [
          nick: "codexbot",
          body: "I can't find a puzzle called #{msg.match[1]}."
        ]
        return
      else
        robot.ddpclient.call "deletePuzzle", [
          id: puzzle.object._id
          who: "codexbot"
        ], (err, res) ->
          if err or not res
            console.log err, res
          else
            robot.ddpclient.call "newMessage", [
              nick: "codexbot",
              body: "Okay, I deleted #{msg.match[1]}."
            ]

## ROUNDS

# newRound
  robot.respond /bot: (.*?) is a new round in group (.*)$/i, (msg) ->
    robot.ddpclient.call "getByName", [
      name: msg.match[2]
      optional_type: "roundgroups"
    ], (err, rg) ->
      if err or not rg
        robot.ddpclient.call "newMessage", [
          nick: "codexbot",
          body: "I can't find a round group called #{msg.match[2]}"
        ]
        return
      else
        robot.ddpclient.call "newRound", [
          name: msg.match[1]
          who: "codexbot"
        ], (err, round) ->
          if err or not round
            console.log err, round
            return
          else
            robot.ddpclient.call "addRoundToGroup", [
              round: round._id
              group: rg.object._id
              who: "codexbot"
            ], (err, res) ->
              if err or not res
                console.log err, res
              else
                robot.ddpclient.call "newMessage", [
                  nick: "codexbot",
                  body: "Okay, I created round #{msg.match[1]} in #{msg.match[2]}."
                ]

# deleteRound
  robot.respond /bot: Delete round (.*)$/i, (msg) ->
    robot.ddpclient.call "getByName", [
      name: msg.match[1]
      optional_type: "rounds"
    ], (err, round) ->
      if err or not round
        robot.ddpclient.call "newMessage", [
          nick: "codexbot",
          body: "I can't find a round called #{msg.match[1]}."
        ]
        return
      else
        robot.ddpclient.call "deleteRound", [
          id: round.object._id
          who: "codexbot"
        ], (err, res) ->
          if err or not res
            console.log err, res
          else
            robot.ddpclient.call "newMessage", [
              nick: "codexbot",
              body: "Okay, I deleted round #{msg.match[1]}."
            ]

## ROUND GROUPS

# newRoundGroup
  robot.respond /bot: (.*?) is a new round group/i, (msg) ->
    robot.ddpclient.call "newRoundGroup", [
      name: msg.match[1]
      who: "codexbot"
    ], (err, rg) ->
      if err or not rg
        console.log err, rg
      else
        robot.ddpclient.call "newMessage", [
          nick: "codexbot",
          body: "Okay, I created round group #{msg.match[1]}."
        ]

# deleteRoundGroup
  robot.respond /bot: Delete round group (.*)$/i, (msg) ->
    robot.ddpclient.call "getByName", [
      name: msg.match[1]
      optional_type: "roundgroups"
    ], (err, rg) ->
      if err or not rg
        robot.ddpclient.call "newMessage", [
          nick: "codexbot",
          body: "I can't find a round group called #{msg.match[1]}"
        ]
        return
      else
        robot.ddpclient.call "deleteRoundGroup", [
          id: rg.object._id
          who: "codexbot"
        ], (err, res) ->
          if err or not res
            console.log err, res
          else
            robot.ddpclient.call "newMessage", [
              nick: "codexbot",
              body: "Okay, I deleted round group #{msg.match[1]}."
            ]
