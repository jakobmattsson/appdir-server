db = require 'manikin-mongodb'
apa = require 'rester'
async = require 'async'
nconf = require 'nconf'
underline = require 'underline'

api = db.create()

getUserFromDb = (req, callback) ->
  callback(null, {})

mod =
  sites:
    fields:
      name: { type: 'string' }
      description: { type: 'string' }

  users:
    fields:
      username:
        type: 'string'
        required: true
        unique: true
      password: { type: 'string', required: true }

  tags:
    fields:
      name: { type: 'string' }


Object.keys(mod).forEach (modelName) ->
  api.defModel modelName, mod[modelName]


exports.run = (settings, callback) ->

  express = require 'express'

  app = express.createServer()
  app.use express.bodyParser()
  app.use express.responseTime()


  nconf.env().argv().defaults
    mongo: 'mongodb://localhost/appdir'
    NODE_ENV: 'development'
    port: 3000

  console.log("Starting up")
  console.log("Environment mongo:", nconf.get('mongo'))
  console.log("Environment NODE_ENV:", nconf.get('NODE_ENV'))

  api.connect nconf.get('mongo'), (err) ->
    if err
      console.log "ERROR: Could not connect to db"
      return

    apa.exec app, api, getUserFromDb, mod
    app.listen nconf.get('port')
    callback()

process.on 'uncaughtException', (ex) ->
  console.log 'Uncaught exception:', ex.message
  console.log ex.stack
  process.exit 1
