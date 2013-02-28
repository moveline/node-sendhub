nock = require 'nock'
sendhub = require '../src/sendhub'
should = require 'should'

describe 'messages', ->
  before ->
    sendhub.username('moveline')
    sendhub.apiKey('moveline-key')

  after ->
    nock.cleanAll()

  describe 'send message', ->
    describe 'with contact and message', ->
      before ->
        scope = nock('https://api.sendhub.com')
          .filteringRequestBody(/.*/, '*')
          .filteringPath( (path) ->
            path = path.replace(/username=[^&]*/g, 'username=XXX')
            path = path.replace(/api_key=[^&]*/g, 'api_key=XXX')
          )
          .post('/v1/messages/?username=XXX&api_key=XXX', '*')
          .reply(201, '{"acknowledgment": "Message queued for sending.", "id": "1"}')

      it 'acknowleges message', (done) ->
        contact = {id: 1111, name: 'Adam Gibbons'}
        sendhub.sendMessage {contact: contact, text: 'Testing'}, (err, response) ->
          should.not.exist(err)
          response.acknowledgment.should.equal 'Message queued for sending.'
          done()

    describe 'when developer does not set required fields', ->
      it 'throws an error for contact', ->
        (->
          sendhub.sendMessage(text: 'Testing')
        ).should.throw()
      it 'throws an error for text', ->
        (->
          sendhub.sendMessage(contact: {id: 1, name: 'Adam Gibbons'})
        ).should.throw()
