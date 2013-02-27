sendhub = require '../src/sendhub'
should = require 'should'

describe 'contacts', ->
  describe 'add contacts', ->
    it 'is true when name and number are set', (done) ->
      sendhub.createContact {number: '9876543210', name: 'Adam Gibbons'}, (err) ->
        should.not.exist(err)
        done()

    it 'throws an error when name not set', ->
      (->
        sendhub.createContact(number: '9876543210')
      ).should.throw()
    it 'throws an error when number not set', ->
      (->
        sendhub.createContact(name: 'Adam Gibbons')
      ).should.throw()
    it 'throws an error when number not ten digits', ->
      ( ->
        sendhub.createContact(name: 'Adam Gibbons', number: '444')
      ).should.throw()

  describe 'list all contacts', ->
     it 'returns a list of contacts', (done) ->
       sendhub.listContacts (err, contacts) ->
         should.not.exist(err)
         contacts.length.should.be.above(0)
         done()
