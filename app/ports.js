'use strict';

const fs = require('fs');

const Elm = require('../dist/elm.js');

const container = document.getElementById('container');
const novelist = Elm.Main.fullscreen(Math.floor(Math.random() * 0x0fffffff));

const projectPath = new URL(document.location).searchParams.get('projectPath');

if (projectPath) {
    fs.readFile(projectPath, (err, data) => {
        if (err) throw err; // TODO: send errors to a port
        console.log('ports open', data.toString());
        openProject(data.toString());
    });
} else {
    // TODO: send some port saying nothing opened mate
}

function openProject(metaData) {
    novelist.ports.openProject.send(metaData);
}
