https = require 'https'
querystring = require 'querystring'

sendHub =
  config: {}

  username: (username) ->
    @config.username = username

  apiKey: (apiKey) ->
    @config.apiKey = apiKey

  createContact: ({name, number}, cb) ->
    unless name? and number?
      throw new Error 'createContact requires name and number'
    unless number.length is 10
      throw new Error 'createContact number length must be 10'

    @request 'POST', '/v1/contacts', {name: name, number: number}, (err, result) ->
      if err?
        return cb(new Error('Could not create contact'))

      cb(null, result)

  request: (method, path, body, cb) ->
    body = body || {}

    if typeof body is 'function'
      cb = body
      body = {}

    body.username = @config.username
    body.api_key = @config.apiKey

    postData = querystring.stringify body

    options =
      method: method
      path: path
      hostname: 'api.sendhub.com'

    if method in ['POST', 'PUT']
      options.header = 
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': postData.length

    req = https.request options, (res) ->
      unless res.statusCode in [200, 201]
        return cb(new Error('Request failed'))

      res.setEncoding('utf8');

      body = ''
      res.on 'data', (chunk) ->
        body += chunk

      res.on 'end', ->
        cb(null, JSON.parse(body))

    req.on 'error', (e) ->
      cb(e)

    req.write(postData)
    req.end()

<<<<<<< HEAD
module.exports = sendHub
=======

module.exports = sendHub
>>>>>>> c9c46ceb7626e7363a5f73d0c26d7b4d751ec8dd
