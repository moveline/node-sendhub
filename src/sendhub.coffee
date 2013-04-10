extend = require 'xtend'
request = require 'request'

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

  auth: ->
    username: @config.username
    api_key: @config.apiKey

  createContact: ({name, number}, cb) ->
    unless name? and number?
      throw new Error 'createContact requires name and number'
    switch number.length
      when 10
        number
      when 12
        number = number[2..]
      else throw new Error 'createContact number length must be 10'

    qs = extend @auth()

    json =
      name: name
      number: number

    req = request.post 'https://api.sendhub.com/v1/contacts/', {json: json, qs: qs}, (err, res) ->
      if err? or res.statusCode isnt 201
        console.log res.statusCode
        return cb(new Error('Could not create contact'))
      cb(null, res.body)

  listContacts: (filterOptions, cb) ->
    if typeof filterOptions is 'function'
      cb = filterOptions
      filterOptions = {}

    qs = extend @auth(), filterOptions

    req = request.get 'https://api.sendhub.com/v1/contacts/', {json: true, qs: qs}, (err, res) ->
      if err?
        return cb(new Error('Could not list contacts'))

      contacts = res.body.objects
      cb(null, contacts)

  sendMessage: ({contact, text}, cb) ->
    unless contact?.id?
      throw new Error('sendMessage requires contact')
    unless text?
      throw new Error('sendMessage requires text')

    qs = extend @auth()

    json =
      contacts: [contact.id]
      text: text

    req = request.post 'https://api.sendhub.com/v1/messages/', {json: json, qs: qs}, (err, res) ->
      if err?
        return cb(new Error('Could not send message'))

      cb(null, res.body)


module.exports = sendHub
