'use strict';

const fs = require('fs');

const Elm = require('./dist/elm.js');

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

// -- MUTATIONS

const observer = new MutationObserver(mutations => {
    mutations.forEach(mutation => {
        if (
            mutation.target.id === 'monaco-editor' &&
            mutation.type === 'attributes' &&
            mutation.attributeName === 'contents'
        ) {
            createMonacoEditor(mutation.target.attributes.contents.textContent);
        }
    });
});
observer.observe(document.querySelector('body'), {
    attributes: true,
    childList: true,
    characterData: true,
    subtree: true
});

// -- MONACO

function createMonacoEditor(contents) {
    const editor = monaco.editor.create(
        document.getElementById('monaco-editor'),
        {
            automaticLayout: true, // TODO: this occurs every 100ms, do it better
            theme: 'novelist-speech',
            language: 'novel',
            // value: thrones(),
            value: contents,
            wordWrap: 'on',
            // wordWrap: "wordWrapColumn",
            // wordWrapColumn: 80,
            lineNumbers: false,
            fontFamily: 'Cochin',
            fontSize: 18,
            lineHeight: 18 * 1.8,
            minimap: {
                renderCharacters: false
            }
        }
    );

    editor.addAction({
        id: 'novelist-character-add',
        label: 'Character: Add new character',
        run: () => {
            console.log('creating a new character');
        }
    });

    var viewZoneId = null;

    editor.onMouseDown(e => {
        return;

        editor.changeViewZones(function(changeAccessor) {
            var domNode = document.createElement('div');
            domNode.style.background = '#F1F1F1';

            const model = editor.getModel();

            const selection = editor.getSelection();

            if (!selection.isEmpty()) {
                domNode.textContent = `New Character: ${model.getValueInRange(
                    selection
                )}`;
            } else {
                domNode.textContent = `New Character: ${model.getWordAtPosition(
                    e.target.position
                ).word}`;
            }

            if (viewZoneId) changeAccessor.removeZone(viewZoneId);
            viewZoneId = changeAccessor.addZone({
                afterLineNumber: e.target.position.lineNumber,
                heightInLines: 6,
                domNode: domNode
            });
        });
    });
}
