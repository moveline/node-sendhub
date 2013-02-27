https = require 'https'
querystring = require 'querystring'

sendHub =
  config: {}

  username: (username) ->
    @config.username = username

<<<<<<< HEAD
    createContact: ({name, number}) ->

    listContacts: ->
}
=======
  apiKey: (apiKey) ->
    @config.apiKey = apiKey
>>>>>>> 3a23bb79e475020874192565a3bdaa7bed6d2360

  createContact: ({name, number}, cb) ->
    unless name? and number?
      throw new Error 'createContact requires name and number'
    unless number.length is 10
      throw new Error 'createContact number length must be 10'

    contactData = querystring.stringify
      username: @config.username
      apiKey: @config.apiKey
      name: name
      number: number

    options =
      hostname: 'api.sendhub.com'
      path: '/v1/contacts'
      method: 'POST'
      headers:
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': contactData.length

    req = https.request options, (res) ->
      unless res.statusCode is 201
        return cb(new Error('Could not create contact'))

      res.setEncoding('utf8');

      body = ''
      res.on 'data', (chunk) ->
        body += chunk

      res.on 'end', ->
        cb(null, JSON.parse(body))


    req.on 'error', (e) ->
      cb(e)

    req.write(contactData)
    req.end()

module.exports = sendHub
