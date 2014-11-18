Q = require 'q'
jsdom = require 'jsdom'
dbConfig = require './dbConfig'
dbSetup = require './dbSetup'
_ = require 'lodash'

document = undefined
window = undefined

jsdom = jsdom.jsdom
express = require 'express'
fs = require 'fs'

r = require 'rethinkdb'

delay = (ms, func) -> setTimeout func, ms
interval = (ms, func) -> setInterval func, ms

express = require 'express'
app = express()

app.use express.static('public')

html = fs.readFileSync 'index.html', 'utf8'

app.get '/', (req, res, next) ->
    res.end html

products = fs.readFileSync 'public/products.html'

app.get '//products.html', (req, res, next) ->
    console.log 'sending //products'
    res.end products

getProducts = (req, res) ->
    type = req.query.type
    query = r.table('products')

    if type?
        query = query.filter type: type

    Q query.run(app.connection)
        .then (cursor) ->
            cursor.toArray()
                .then (rows) ->
                    console.log 'rows', rows
                    res.end JSON.stringify rows
        .fail (err) ->
            console.log 'error', err
        .done()

app.get '//products', (req, res, next) ->
    getProducts req, res

app.get '/products', (req, res, next) ->
    getProducts req, res

app.get "*", (req, res, next) ->
    console.log window.document.location
    e = window.document.getElementById 'mainctl'
    if window.angular?
        scope = window.angular.element(e).scope()
        scope.$apply ->
            scope.setLocation req.url
            return undefined
        delay 50, ->
            console.log window.document.innerHTML
            res.end window.document.innerHTML
    else
        console.log 'window.angular is not defined'
        console.log window.document.innerHTML

process.on 'uncaughtException', (err) ->
    console.log 'Uncaught exception:'
    console.log err
    console.log err.stack

startApp = (connection) ->
    app.connection = connection
    document = jsdom html
    window = document.defaultView

    app.listen 3002
    console.log 'Listening on port 3002'

r.connect({ host: 'localhost', port: 28015 }).then (connection) ->
    console.log 'connected'
    connection['_id'] = Math.floor Math.random() * 10001
    dbSetup(dbConfig).then () ->
        startApp connection

