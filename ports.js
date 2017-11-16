'use strict';

// const path = require('path');
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
    const filePath = path.join(projectPath, 'files', `${fileId}.txt`);
    console.log('requesting file', filePath);
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

novelist.ports.searchPort.subscribe(term => {
    const dir = path.join(projectPath, 'files');
    fs
        .readdir(dir)
        .then(fileNames =>
            fileNames.reduce(
                (promise, fileName) =>
                    promise.then(files =>
                        fs
                            .readFile(path.join(dir, fileName), 'utf-8')
                            .then(contents => {
                                if (!contents.includes(term)) {
                                    return files;
                                }

                                const indices = getIndicesOf(term, contents);
                                const matches = indices.map(index => {
                                    let numSpaces = 0;
                                    let left = index;
                                    while (left > 0 && numSpaces < 3) {
                                        left -= 1;
                                        if (contents[left] === ' ') {
                                            numSpaces += 1;
                                        }
                                        if (contents[left] === '\n') break;
                                    }
                                    numSpaces = 0;
                                    let right = index + term.length;
                                    while (
                                        right < contents.length - 1 &&
                                        numSpaces < 3
                                    ) {
                                        right += 1;
                                        if (contents[right] === ' ') {
                                            numSpaces += 1;
                                        }
                                        if (contents[right] === '\n') break;
                                    }
                                    return contents.slice(left, right).trim();
                                });

                                return Object.assign({}, files, {
                                    [fileName]: matches
                                });
                            })
                    ),
                Promise.resolve({})
            )
        )
        .then(files => {
            novelist.ports.searchSubscription.send(JSON.stringify(files));
        });
});

// -- PORTS

function openProject(meta) {
    novelist.ports.openProjectSubscription.send(meta);
}

function updateFile(contents) {
    novelist.ports.updateFileSubscription.send(contents);
}

// -- FILES

function writeFile(fileId, contents) {
    fs.writeFile(
        `${projectPath}/files/${fileId}.txt`,
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

        if (!document.getElementById('monaco-editor')) {
            destroyMonacoEditor();
        }
    });
});
observer.observe(document.querySelector('body'), {
    childList: true,
    characterData: true,
    attributes: true,
    subtree: true
});

// -- MONACO

let editor;

function destroyMonacoEditor() {
    if (editor) {
        const model = editor.getModel();
        if (model) model.dispose();
        editor.dispose();
    }
}

function createMonacoEditor(contents) {
    destroyMonacoEditor();

    // -- Create the editor
    editor = monaco.editor.create(document.getElementById('monaco-editor'), {
        automaticLayout: true, // TODO: this occurs every 100ms, do it better
        theme: 'novelist-speech',
        language: 'novel',
        value: contents,
        wordWrap: 'wordWrapColumn',
        wordWrapColumn: 70,
        lineNumbers: false,
        fontFamily: 'Cochin',
        fontSize: 18,
        lineHeight: 18 * 1.8,
        minimap: {
            enabled: false,
            renderCharacters: false
        }
    });

    // -- Attach a listener to automatically save the file
    const model = editor.getModel();
    model.onDidChangeContent(() => {
        const value = model.getValue();
        writeFile(activeFileId, value);
    });

    // editor.addAction({
    //     id: 'novelist-character-add',
    //     label: 'Character: Add new character',
    //     run: () => {
    //         console.log('creating a new character');
    //     }
    // });

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

// -- UTILS

// https://stackoverflow.com/a/3410557
function getIndicesOf(searchStr, str, caseSensitive = false) {
    var searchStrLen = searchStr.length;
    if (searchStrLen == 0) {
        return [];
    }
    var startIndex = 0,
        index,
        indices = [];
    if (!caseSensitive) {
        str = str.toLowerCase();
        searchStr = searchStr.toLowerCase();
    }
    while ((index = str.indexOf(searchStr, startIndex)) > -1) {
        indices.push(index);
        startIndex = index + searchStrLen;
    }
    return indices;
}
