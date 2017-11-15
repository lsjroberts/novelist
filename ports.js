'use strict';

const fs = require('fs-extra');

const Elm = require('./dist/elm.js');

// -- PROGRAM

const container = document.getElementById('container');
const novelist = Elm.Main.fullscreen(Math.floor(Math.random() * 0x0fffffff));
let activeFileId;

// -- INIT

const projectPath =
    new URL(document.location).searchParams.get('projectPath') || '.tmp';

if (projectPath) {
    fs.readFile(`${projectPath}/meta.json`, (err, data) => {
        if (err) throw err; // TODO: send errors to a port
        openProject(data.toString());
    });
} else {
    // TODO: send some port saying nothing opened mate
}

// -- SUBSCRIPTIONS

novelist.ports.writeMetaPort.subscribe(json => {
    const filePath = `${projectPath}/meta.json`;
    fs.writeFile(filePath, JSON.stringify(json, null, 2), err => {
        if (err) throw err; // TODO: send errors to a port
    });
});

novelist.ports.requestFilePort.subscribe(fileId => {
    const filePath = `${projectPath}/manuscript/${fileId}.txt`;
    fs.ensureFile(filePath, err => {
        if (err) throw err; // TODO: send errors to a port
        fs.readFile(filePath, (err, data) => {
            if (err) throw err; // TODO: send errors to a port
            activeFileId = fileId;
            updateFile(data.toString());
        });
    });
});

novelist.ports.writeFilePort.subscribe(writeFile);

// -- PORTS

function openProject(meta) {
    novelist.ports.openProjectPort.send(meta);
}

function updateFile(contents) {
    novelist.ports.updateFilePort.send(contents);
}

// -- FILES

function writeFile(fileId, contents) {
    fs.writeFile(
        `${projectPath}/manuscript/${fileId}.txt`,
        contents,
        (err, data) => {
            if (err) throw err; // TODO: send errors to a port
        }
    );
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
    subtree: true
});

// -- MONACO

let editor;
function createMonacoEditor(contents) {
    if (editor) {
        editor.getModel().dispose();
        editor.dispose();
    }

    // -- Create the editor
    editor = monaco.editor.create(document.getElementById('monaco-editor'), {
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
    });

    // -- Attach a listener to automatically save the file
    const model = editor.getModel();
    model.onDidChangeContent(() => {
        const value = model.getValue();
        writeFile(activeFileId, value);
    });

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
