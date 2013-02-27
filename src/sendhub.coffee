https = require 'https'

sendHub = {
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

      options = {
        hostname: 'api.sendhub.com'
        path: "/v1/contacts/?username=#{@config.username}&api_key=#{@config.apiKey}"
        method: 'POST'
      }

      req = https.request options, (res) ->
        console.log "statusCode: ", res.statusCode
        console.log "headers: ", res.headers

        res.on 'data', (d) ->
          console.log d

      req.end()

      req.on 'error', (e) ->
        console.log e
}