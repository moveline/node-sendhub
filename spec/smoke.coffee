if process.env.SENDHUB_USERNAME? or process.env.SENDHUB_APIKEY?
  sendhub = require '../src/sendhub'
  should = require 'should'

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
        sendhub.sendMessage {contact: {id: 4561514}, text: 'Testing from node package'}, (err, response) ->
          should.not.exist(err)
          response.acknowledgment.should.equal 'Message queued for sending.'
          done()
