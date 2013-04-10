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

    if number.match(/[^\d+]/)
      throw new Error 'createContact number must only be digits'

    # Removes +1 country code
    if number.length is 12 and number.indexOf('+1') is 0
      number = number[2..]

    # Sendhub only supports 10 digits
    unless number.length is 10
      throw new Error 'createContact number length must be 10'

    qs = extend @auth()

    json =
      name: name
      number: number

    log.debug "Sendhub Request: Create Contact ('#{name}', #{number})"
    req = request.post 'https://api.sendhub.com/v1/contacts/', {json: json, qs: qs}, (err, res) ->
      if err? or res.statusCode isnt 201
        return cb(new Error('Could not create contact'))
      cb(null, res.body)

  listContacts: (filterOptions, cb) ->
    if typeof filterOptions is 'function'
      cb = filterOptions
      filterOptions = {}

    qs = extend @auth(), filterOptions

    log.debug "Sendhub Request: List Contacts"
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

    log.debug "Sendhub Request: Send Message (#{contact.id}, text)"
    req = request.post 'https://api.sendhub.com/v1/messages/', {json: json, qs: qs}, (err, res) ->
      if err?
        return cb(new Error('Could not send message'))

      cb(null, res.body)


module.exports = sendHub
