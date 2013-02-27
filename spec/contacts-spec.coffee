nock = require 'nock'
sendhub = require '../src/sendhub'
should = require 'should'

describe 'contacts', ->
  describe 'add contacts', ->
    before ->
      sendhub.username('moveline')
      sendhub.apiKey('moveline-key')

    after ->
      nock.restore()

    describe 'with name and number', ->
      before ->
        scope = nock('https://api.sendhub.com')
          .filteringRequestBody(/.*/, '*')
          .post('/v1/contacts', '*')
          .reply(201, '{"id": "1", "name": "Adam Gibbons", "number": "9876543210"}')

      it 'returns a contact', (done) ->
        sendhub.createContact {number: '9876543210', name: 'Adam Gibbons'}, (err, contact) ->
          should.not.exist(err)
          contact.should.have.keys ['id', 'name', 'number']
          done()

    describe 'when sendhub errors', ->
      before ->
        scope = nock('https://api.sendhub.com')
          .filteringRequestBody(/.*/, '*')
          .post('/v1/contacts', '*')
          .reply(500, 'SERVER FUCKED')

      it 'return an error', (done) ->
        sendhub.createContact {number: '9876543210', name: 'Adam Gibbons'}, (err) ->
          should.exist(err)
          done()

    describe 'when developer does not set required fields', ->
      it 'throws an error for name', ->
        (->
          sendhub.createContact(number: '9876543210')
        ).should.throw()
      it 'throws an error for number', ->
        (->
          sendhub.createContact(name: 'Adam Gibbons')
        ).should.throw()
      it 'throws an error for number under 10 digits', ->
        ( ->
          sendhub.createContact(name: 'Adam Gibbons', number: '444')
        ).should.throw()

      it 'throws an error for number over 10 digits', ->
        ( ->
          sendhub.createContact(name: 'Adam Gibbons', number: '98765432109')
        ).should.throw()
