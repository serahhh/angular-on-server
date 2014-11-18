module.exports =
    host: 'localhost'
    port: 28015
    db: 'test'
    tables:
        products:
            key: 'id'
            rows: [
                { type: 'outdoor', name: 'Deck Set', price: 189.95 }
                { type: 'outdoor', name: 'Patio Set', price: 259.95 }
                { type: 'electronics', name: 'iPhone 12', price: 899.95 }
                { type: 'electronics', name: 'Chromebook', price: 259.95 }
            ]