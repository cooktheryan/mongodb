//Create the pacman database with user and password
var MongoClient = require('mongodb').MongoClient;  
var url = "mongodb://localhost:27017/pacman";  
MongoClient.connect(url, function(err, db) {  
if (err) throw err;  
console.log("Database created!");  
db.close();  
});  
db.createUser({
    user: "pacman",
    pwd: "pacman",
    roles: [
        { role: "readWrite", db: "pacman"}
    ]
})