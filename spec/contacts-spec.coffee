nock = require 'nock'
sendhub = require '../src/sendhub'
should = require 'should'

describe 'contacts', ->
  before ->
    sendhub.username('moveline')
    sendhub.apiKey('moveline-key')

  after ->
    nock.cleanAll()

  describe 'add contacts', ->
    describe 'with name and number', ->
      beforeEach ->
        scope = nock('https://api.sendhub.com')
          .filteringRequestBody(/.*/, '*')
          .filteringPath( (path) ->
            path = path.replace(/username=[^&]*/g, 'username=XXX')
            path = path.replace(/api_key=[^&]*/g, 'api_key=XXX')
          )
          .post('/v1/contacts/?username=XXX&api_key=XXX', '*')
          .reply(201, '{"id": "1", "name": "Adam Gibbons", "number": "9876543210"}')

      it 'returns a contact', (done) ->
        sendhub.createContact {number: '9876543210', name: 'Adam Gibbons'}, (err, contact) ->
          should.not.exist(err)
          contact.should.have.keys ['id', 'name', 'number']
          done()

      it 'handles numbers prefixed with +1', (done) ->
        sendhub.createContact {number: '+19876543210', name: 'Adam Gibbons'}, (err, contact) ->
          should.not.exist(err)
          contact.should.have.keys ['id', 'name', 'number']
          done()

    describe 'when sendhub errors', ->
      before ->
        scope = nock('https://api.sendhub.com')
          .filteringRequestBody(/.*/, '*')
          .filteringPath( (path) ->
            path = path.replace(/username=[^&]*/g, 'username=XXX')
            path = path.replace(/api_key=[^&]*/g, 'api_key=XXX')
          )
          .post('/v1/contacts/?username=XXX&api_key=XXX', '*')
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

      it 'throws an error when number has 10 letters', ->
        ( ->
          sendhub.createContact(name: 'Adam Gibbons', number: 'abcdefghij')
        ).should.throw()

      it 'throws an error for number under 10 digits', ->
        ( ->
          sendhub.createContact(name: 'Adam Gibbons', number: '444')
        ).should.throw()

      it 'throws an error for number over 10 digits that doesn\'nt begin with +1', ->
        ( ->
          sendhub.createContact(name: 'Adam Gibbons', number: '98765432109')
        ).should.throw()

  describe 'list contacts', ->
    before ->
      scope = nock('https://api.sendhub.com')
        .filteringPath( (path) ->
          path = path.replace(/username=[^&]*/g, 'username=XXX')
          path = path.replace(/api_key=[^&]*/g, 'api_key=XXX')
        )
        .get('/v1/contacts/?username=XXX&api_key=XXX')
        .reply(200, '{"meta": {}, "objects": [{"id": "1", "name": "Moveline", "number": "9876543210"}]}')

    it 'returns a list of contacts', (done) ->
      sendhub.listContacts (err, contacts) ->
        should.not.exist(err)
        contacts.length.should.be.above(0)
        done()

    describe 'when a limit is given', (done) ->
      before ->
        scope = nock('https://api.sendhub.com')
          .filteringPath( (path) ->
            path = path.replace(/username=[^&]*/g, 'username=XXX')
            path = path.replace(/api_key=[^&]*/g, 'api_key=XXX')
          )
          .get('/v1/contacts/?username=XXX&api_key=XXX&limit=1')
          .reply(200, '{"meta": {}, "objects": [{"id": "1", "name": "Moveline", "number": "1234567890"}]}')

      it 'returns a list less or equal to the limit', ->
        sendhub.listContacts {limit: 1}, (err, contacts) ->
          should.not.exist(err)
          contacts.length.should.be.above(0).and.be.below(2)

    describe 'when filtering by number', (done) ->
      before ->
        scope = nock('https://api.sendhub.com')
          .filteringPath( (path) ->
            path = path.replace(/username=[^&]*/g, 'username=XXX')
            path = path.replace(/api_key=[^&]*/g, 'api_key=XXX')
            path = path.replace(/number=[^&]*/g, 'number=XXX')
          )
          .get('/v1/contacts/?username=XXX&api_key=XXX&number=XXX')
          .reply(200, '{"meta": {}, "objects": [{"id": "1", "name": "Moveline", "number": "1234567890"}]}')

      it 'returns a list of contacts with the number', (done) ->
        sendhub.listContacts {number: '1234567890'}, (err, contacts) ->
          should.not.exist(err)
          contacts.should.have.length(1)

          contacts.forEach (contact) ->
            contact.should.have.property('number').with.eql('1234567890')

          done()
