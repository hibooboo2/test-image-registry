var shelljs = require('shelljs'),
    url = require('url'),
    http = require('http'),
    express = require('express'),
    app = express(),
    server = require('http').createServer(app),
    bodyParser = require('body-parser'),
    multer = require('multer');

file = '/src/.htpasswd';

app.use(bodyParser.json()); // for parsing application/json
app.use(bodyParser.urlencoded({ extended: true })); // for parsing application/x-www-form-urlencoded
app.use(multer()); // for parsing multipart/form-data

server.listen(process.env.PORT ? process.env.PORT : 8080);

app.use('/signup', express.static(__dirname + '/'));

app.post('/signup',function(req, res){
    signup(req.body, req, res)
})

function signup(user, req, res){
    if (user.password && user.username){
        shelljs.exec('htpasswd -bm '+file + " " +user.username + " " + user.password)
        res.send("User:"+req.query['username']+"\nPassword:"+req.query['password']
        + "\n"+ JSON.stringify(req.body));
        console.log("Added user" + user);
    }
}

console.log('Server running at localhost:8080');
