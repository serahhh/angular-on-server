Q = require 'q'
r = require 'rethinkdb'
_ = require 'lodash'

createTable = (db, connection, table) ->
    console.log 'table', table
    Q.ninvoke db.tableCreate(table.name, { primaryKey: table.key }).run connection
        .then (result) ->
            console.log "Table `#{table.name}` created"
        .fail (err) ->
            if ~err.msg.indexOf 'already exists'
                console.log "Table `#{table.name}` already exists"
                console.log "Deleting rows"
                return Q db.table(table.name).delete().run connection
            throw err
        .then () ->
            tbl = db.table table.name
            promises = []

            for row in table.rows
                promises.push tbl.insert(row).run connection

            Q.allSettled promises

module.exports = (config) ->
    deferred = Q.defer()

    r.connect host: config.host, port: config.port
        .then (connection) ->
            Q.ninvoke r.dbCreate(config.db).run connection
                .then (result) ->
                    console.log "DB `#{config.db}` created"
                .fail (err) ->
                    if ~err.msg.indexOf 'already exists'
                        console.log "DB `#{config.db}` already exists"
                    else
                        deferred.reject err
                .then () ->
                    promises = []

                    for tableName, tableData of config.tables
                        promises.push createTable(r.db(config.db), connection, _.extend { name: tableName }, tableData)

                    Q.allSettled(promises).then () ->
                        deferred.resolve()

    deferred.promise