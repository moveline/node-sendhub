if process.env.SENDHUB_USERNAME? and process.env.SENDHUB_APIKEY? and process.env.SENDHUB_DEVELOPER_ID?
  sendhub = require '../src/sendhub'
  should = require 'should'

  # Global to be resued by other tests
  owner = {id: process.env.SENDHUB_DEVELOPER_ID}

  describe 'Smoke Tests against SendHub', ->
    before ->
      sendhub.username(process.env.SENDHUB_USERNAME)
      sendhub.apiKey(process.env.SENDHUB_APIKEY)

    after ->
      sendhub.config = {}

    describe 'list contacts', ->
      it 'returns more than 1', (done) ->
        sendhub.listContacts (err, contacts) ->
          should.not.exist(err)
          contacts.length.should.be.above(0)
          done()

    describe 'send message', ->
      it 'is successful', (done) ->
        sendhub.sendMessage {contact: owner, text: 'Testing from node package'}, (err, response) ->
          should.not.exist(err)
          response.acknowledgment.should.equal 'Message queued for sending.'
          done()
