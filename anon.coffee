Twit = require 'twit'
wikichanges = require 'wikichanges'

ipToQuad = (ip) ->
  return (parseInt(s) for s in ip.split('.'))

compareIps = (ip1, ip2) ->
  q1 = ipToQuad(ip1)
  q2 = ipToQuad(ip2)
  if "#{q1}" is "#{q2}"
    r = 0
  else if q1 < q2
    r = -1
  else
    r = 1
  return r

isIpInRange = (ip, block) ->
  return compareIps(ip, block[0]) >= 0 and compareIps(ip, block[1]) <= 0

isIpInAnyRange = (ip, blocks) ->
  for block in blocks
    if isIpInRange(ip, block)
      return true
  return false

main = ->
  config = require './config.json'
  twitter = new Twit config
  wikipedia = new wikichanges.WikiChanges(ircNickname: config.nick)
  wikipedia.listen (edit) ->
    # if we have an anonymous edit, then edit.user will be the ip address
    # we iterate through each group of ip ranges looking for a match
    if edit.anonymous
      for name, ranges of config.ranges
        if isIpInAnyRange edit.user, ranges
          status = 'Статья в Википедии ' + edit.page + ' была отредактирована ' + name + ' ' + edit.url
          console.log status
          twitter.post 'statuses/update', status: status, (err, d, r) ->
            if err
              console.log err
          return

if require.main == module
  main()

# export these for testing
exports.compareIps = compareIps
exports.isIpInRange = isIpInRange
exports.isIpInAnyRange = isIpInAnyRange
