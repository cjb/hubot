# Description:
#   Utility commands for Codexbot
#
# Commands:
#   hubot: bot: The answer to <puzzle> is <answer>
#   hubot: bot: Delete the answer to <puzzle>
#   hubot: bot: <puzzle> is a new puzzle in round <round>
#   hubot: bot: Delete puzzle <puzzle>
#   hubot: bot: <round> is a new round in group <group>
#   hubot: bot: Delete round <name>
#   hubot: bot: <roundgroup> is a new round group
#   hubot: bot: Delete round group <roundgroup>

module.exports = (robot) ->

## ANSWERS

# setAnswer
  robot.respond /bot: The answer to (.*?) is (.*)$/i, (msg) ->
    robot.ddpclient.call "getByName", [
      name: msg.match[1]
      optional_type: "puzzles"
    ], (err, puzzle) ->
      if err or not puzzle
        console.log err, puzzle
        return
      else
        robot.ddpclient.call "setAnswer", [
          puzzle: puzzle.object._id
          answer: msg.match[2]
          who: "codexbot"
        ], (err, res) ->
          if err or not res
            console.log err, res

# deleteAnswer
  robot.respond /bot: Delete the answer to (.*)$/i, (msg) ->
    robot.ddpclient.call "getByName", [
      name: msg.match[1]
      optional_type: "puzzles"
    ], (err, puzzle) ->
      if err or not puzzle
        console.log err, puzzle
        return
      else
        robot.ddpclient.call "deleteAnswer", [
          puzzle: puzzle.object._id
          who: "codexbot"
        ], (err, res) ->
          if err or not res
            console.log err, res

## PUZZLES

# newPuzzle
  robot.respond /bot: (.*?) is a new puzzle in round (.*)$/i, (msg) ->
    robot.ddpclient.call "getByName", [
      name: msg.match[2]
      optional_type: "rounds"
    ], (err, round) ->
      if err or not round
        console.log err, round
        return
      else
        robot.ddpclient.call "newPuzzle", [
          name: msg.match[1]
          who: "codexbot"
        ], (err, puzzle) ->
          if err or not puzzle
            console.log err, puzzle
            return
          else
            robot.ddpclient.call "addPuzzleToRound", [
              round: round.object._id
              puzzle: puzzle._id
              who: "codexbot"
            ], (err, res) ->
              if err or not res
                console.log err, res

# deletePuzzle
  robot.respond /bot: Delete puzzle (.*)$/i, (msg) ->
    robot.ddpclient.call "getByName", [
      name: msg.match[1]
      optional_type: "puzzles"
    ], (err, puzzle) ->
      if err or not puzzle
        console.log err, puzzle
        return
      else
        robot.ddpclient.call "deletePuzzle", [
          id: puzzle.object._id
          who: "codexbot"
        ], (err, res) ->
          if err or not res
            console.log err, res

## ROUNDS

# newRound
  robot.respond /bot: (.*?) is a new round in group (.*)$/i, (msg) ->
    robot.ddpclient.call "getByName", [
      name: msg.match[2]
      optional_type: "roundgroups"
    ], (err, rg) ->
      if err or not rg
        console.log err, rg
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

# deleteRound
  robot.respond /bot: Delete round (.*)$/i, (msg) ->
    robot.ddpclient.call "getByName", [
      name: msg.match[1]
      optional_type: "rounds"
    ], (err, round) ->
      if err or not round
        console.log err, round
        return
      else
        robot.ddpclient.call "deleteRound", [
          id: round.object._id
          who: "codexbot"
        ], (err, res) ->
          if err or not res
            console.log err, res

## ROUND GROUPS

# newRoundGroup
  robot.respond /bot: (.*?) is a new round group/i, (msg) ->
    robot.ddpclient.call "newRoundGroup", [
      name: msg.match[1]
      who: "codexbot"
    ], (err, rg) ->
      if err or not rg
        console.log err, rg

# deleteRoundGroup
  robot.respond /bot: Delete round group (.*)$/i, (msg) ->
    robot.ddpclient.call "getByName", [
      name: msg.match[1]
      optional_type: "roundgroups"
    ], (err, rg) ->
      if err or not rg
        console.log err, rg
        return
      else
        robot.ddpclient.call "deleteRoundGroup", [
          id: rg.object._id
          who: "codexbot"
        ], (err, res) ->
          if err or not res
            console.log err, res
