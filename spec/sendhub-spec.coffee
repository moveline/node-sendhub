sendhub = require '../src/sendhub'
should = require 'should'

describe 'sendhub', ->
  it 'returns an object', ->
    sendhub.should.be.a('object')

  it 'takes username', ->
    ( ->
      sendhub.username('moveline')
    ).should.not.throw()

  it 'takes token', ->
    ( ->
      sendhub.token('moveline-token')
    ).should.not.throw()

