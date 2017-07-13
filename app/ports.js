'use strict';

const querystring = require('querystring');
const fs = require('fs');
const findIndex = require('lodash/findIndex');

const Elm = require('./elm.js');

const container = document.getElementById('container');
const novelist = Elm.Main.embed(container);


// -- MAIN

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


// -- SUBSCRIPTIONS

novelist.ports.setStorage.subscribe((state) => {
  localStorage.setItem('model', JSON.stringify(state));
});

document.onselectionchange = (evt) => {
  const selection = document.getSelection();
  const range = selection.getRangeAt(0);

  if (range.startContainer !== range.endContainer) {
    console.warn('trying to select in multiple nodes');
    return;
  }

  const paragraph = range.startContainer.parentElement;
  const article = paragraph.parentElement;

  novelist.ports.select.send({
    start: range.startOffset,
    end: range.endOffset,
    paragraphIndex: findIndex(article.children, (el) => el === paragraph),
  })
};
