_ = require 'underscore'
team = try require process.env.HUBOT_TEAM_PATH

exports.extractMentions = (body) ->
  mentions = []
  match = body.match /(^|\s)(@[\w\-\/]+)/g
  if match
    mentions = _.uniq(mention.trim() for mention in match)
  mentions

exports.buildMessage = (parts, opts) ->
  return null unless parts
  mentions = convert parts.mentions
  random_mentions = if parts.random then random(mentions, opts.random_mention, opts.mention_team) else []
  return null if opts.only_mentioned and mentions.length is 0 and random_mentions.length is 0
  repository_name = parts.repository.match(/[^\/]+?\/(.+)$/)?[1]
  message_body = parts.body.replace(/^@\S+\s/, '')
  msg = ""
  msg += "<#{parts.url}|##{parts.number} #{parts.title} (#{repository_name})>\n"
  msg += "#{mentions.join(" ")}: " if mentions.length
  msg += "#{message_body} by @#{parts.user}\n"
  msg += "Congratulations! You are assigned: #{random_mentions.join(", ")}\n" if random_mentions.length
  msg

convert = (github_mentions) ->
  return github_mentions unless team
  mentions = []
  for github_mention in github_mentions
    if team[github_mention]
      mention = team[github_mention]
    else
      for name, converter of team
        if _.isObject(converter) and converter[github_mention]
          mention = converter[github_mention]
    mentions.push mention if mention
  mentions

random = (mentions, random_mention, mention_team) ->
  return [] unless team and random_mention
  num = random_mention - mentions.length
  return [] unless num
  sample = team[mention_team] or team
  _.chain(sample).values().difference(mentions).sample(num).value()
