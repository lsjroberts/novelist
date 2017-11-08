'use strict';

const fs = require('fs');

const Elm = require('../dist/elm.js');

// -- PROGRAM

const container = document.getElementById('container');
const novelist = Elm.Main.fullscreen(Math.floor(Math.random() * 0x0fffffff));

// -- INIT

const projectPath = new URL(document.location).searchParams.get('projectPath');

if (projectPath) {
    fs.readFile(`${projectPath}/meta.json`, (err, data) => {
        if (err) throw err; // TODO: send errors to a port
        console.log('ports open', data.toString());
        openProject(data.toString());
    });
} else {
    // TODO: send some port saying nothing opened mate
}

// -- SUBSCRIPTIONS

novelist.ports.requestFile.subscribe(fileId => {
    fs.readFile(`${projectPath}/manuscript/${fileId}.txt`, (err, data) => {
        if (err) throw err; // TODO: send errors to a port
        openFile(data.toString());
    });
});

// -- PORTS

function openProject(meta) {
    novelist.ports.openProject.send(meta);
}

function openFile(contents) {
    novelist.ports.openFile.send(contents);
}
