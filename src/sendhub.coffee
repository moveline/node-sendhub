https = require 'https'
querystring = require 'querystring'

log =
  debug: (message) ->
    if process.env.LOG_LEVEL is 'debug'
      console.log message

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

    @request 'POST', '/v1/contacts/', {name: name, number: number}, (err, result) ->
      if err?
        return cb(new Error('Could not create contact'))

      cb(null, result)

  listContacts: (cb) ->
    @request 'GET', '/v1/contacts/', (err, contacts) ->
      if err?
        return cb(new Error('Could not list contacts'))

      if contacts.length < 1
        return cb(new Error('No contacts where returned'))

      cb(null, contacts)

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
      log.debug "#{path} returned a status code of #{res.statusCode}"
      unless res.statusCode in [200, 201]
        return cb(new Error('Request failed'))

      res.setEncoding('utf8');

      body = ''
      res.on 'data', (chunk) ->
        body += chunk

      res.on 'end', ->
        log.debug body
        cb(null, JSON.parse(body))

    req.on 'error', (e) ->
      cb(e)

    req.write(postData)
    req.end()

module.exports = sendHub
