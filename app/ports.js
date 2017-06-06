'use strict';

const querystring = require('querystring');
const fs = require('fs');

const Elm = require('./elm.js');

const container = document.getElementById('container');
const novelist = Elm.Main.embed(container);

novelist.ports.setStorage.subscribe((state) => {
  localStorage.setItem('model', JSON.stringify(state));
});

const query = querystring.parse(window.location.search.replace('?', ''));

if (query && query.projectPath && query.projectPath !== 'undefined') {
    fs.readFile(query.projectPath, (err, data) => {
        if (err) throw err; // TODO: send errors to a port
        console.log(data.toString());
        openProject(data.toString());
    });
} else {
    // TODO: send some port saying nothing opened mate
}

function openProject(metaData) {
    novelist.ports.openProject.send(metaData);
}
