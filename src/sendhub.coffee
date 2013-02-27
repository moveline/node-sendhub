sendHub = {
    config: {}

    username: (username) ->
        @config.username = username

    apiKey: (apiKey) ->
        @config.apiKey = apiKey
}

module.exports = sendHub
