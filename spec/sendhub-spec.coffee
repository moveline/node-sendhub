sendhub = require '../src/sendhub'
should = require 'should'

describe 'sendhub', ->
  it 'returns an object', ->
    sendhub.should.be.a('object')

  it 'takes username', ->
    ( ->
      sendhub.username('moveline')
    ).should.not.throw()

  it 'takes api key', ->
    ( ->
      sendhub.apiKey('moveline-key')
    ).should.not.throw()

