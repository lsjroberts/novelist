var path = require('path');
function uriFromPath(_path) {
    var pathName = path.resolve(_path).replace(/\\/g, '/');
    if (pathName.length > 0 && pathName.charAt(0) !== '/') {
        pathName = '/' + pathName;
    }
    return encodeURI('file://' + pathName);
}

amdRequire.config({
    baseUrl: uriFromPath(
        path.join(__dirname, './node_modules/monaco-editor/min')
    )
});

// workaround monaco-css not understanding the environment
self.module = undefined;

// workaround monaco-typescript not understanding the environment
self.process.browser = true;

amdRequire(['vs/editor/editor.main'], function() {
    // Register a new language
    monaco.languages.register({ id: 'novel' });

    // Register a tokens provider for the language
    monaco.languages.setMonarchTokensProvider('novel', {
        tokenizer: {
            root: [
                ['["“][^"”]+["”]?', 'speech'],
                ['Mr. Bennet', 'character'],
                ['Mrs. Bennet', 'character']
            ]
        }
    });

    monaco.languages.setLanguageConfiguration('novel', {
        indentationRules: {
            // increaseIndentPattern: new RegExp(/^[^\s]/)
            // indentNextLinePattern: new RegExp(/^[^\s]/)
        }
        // onEnterRules: [
        //   {
        //     action: { indentAction: monaco.languages.IndentAction.Indent }
        //   }
        // ]
    });

    // const defaultThemeColors = {
    //   "editor.background": colorsHash.base3,
    //   "editor.foreground": colorsHash.base0,
    //   "editorHoverWidget.background": colorsHash.base03,
    //   "editorLineNumber.foreground": colorsHash.base2
    // };

    const defaultThemeColors = {
        // "editor.background": "#F7F7F7",
        'editor.background': '#F3F3F3',
        'editor.foreground': '#333333',
        'editorHoverWidget.background': '#F3F3F3',
        'editorLineNumber.foreground': '#F3F3F3',
        'editor.lineHighlightBackground': '#F3F3F3',
        'editor.lineHighlightBorder': '#00000000'
    };

    const defaultThemeRules = [{ token: 'source', foreground: colors.base02 }];
    const speechThemeRules = defaultThemeRules.concat([
        // { token: "character", foreground: "B58900" },
        // { token: "speech", foreground: "2AA198" }
        { token: 'character', foreground: '3377B9' },
        // { token: "character", foreground: "B14FA2" },
        // { token: "speech", foreground: "40831E" }
        { token: 'speech', foreground: 'B14FA2' }
    ]);

    // Define a new theme that constains only rules that match this language
    monaco.editor.defineTheme('novelist', {
        base: 'vs',
        colors: defaultThemeColors,
        inherit: false,
        rules: defaultThemeRules
    });

    monaco.editor.defineTheme('novelist-speech', {
        base: 'vs',
        colors: defaultThemeColors,
        inherit: false,
        rules: speechThemeRules
    });

    monaco.languages.registerHoverProvider('novel', {
        provideHover: function(model, position) {
            const token = getTokenAtPosition(model, position);

            return {
                range: new monaco.Range(
                    position.lineNumber,
                    token.offset + 1,
                    position.lineNumber,
                    token.offset + token.length + 1
                ),
                contents: [
                    `**${token.text}**`,
                    { language: 'novel', value: 'A character' }
                ]
            };
        }
    });
});

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
        language: 'novel',
        lineHeight: 18 * 1.8,
        lineNumbers: false,
        fontFamily: 'Cochin',
        fontSize: 18,
        minimap: {
            enabled: false,
            renderCharacters: false
        },
        occurrencesHighlight: false,
        scrollBeyondLastLine: false,
        theme: 'novelist-speech',
        value: contents,
        wordWrap: 'wordWrapColumn',
        wordWrapColumn: 70
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

    editor.onMouseDown(event => {
        const token = getTokenAtPosition(model, event.target.position);

        editor.changeViewZones(function(changeAccessor) {
            if (viewZoneId) changeAccessor.removeZone(viewZoneId);

            if (!token) return;

            if (token.type !== 'character.novel') return;

            var domNode = document.createElement('div');
            domNode.style.background = '#F1F1F1';
            domNode.textContent = `Character: ${token.text}`;

            viewZoneId = changeAccessor.addZone({
                afterLineNumber: event.target.position.lineNumber,
                heightInLines: 6,
                domNode: domNode
            });
        });

        return;

        // editor.changeViewZones(function(changeAccessor) {
        //     var domNode = document.createElement('div');
        //     domNode.style.background = '#F1F1F1';

        //     const model = editor.getModel();

        //     const selection = editor.getSelection();

        //     if (!selection.isEmpty()) {
        //         domNode.textContent = `New Character: ${model.getValueInRange(
        //             selection
        //         )}`;
        //     } else {
        //         domNode.textContent = `New Character: ${model.getWordAtPosition(
        //             e.target.position
        //         ).word}`;
        //     }

        //     if (viewZoneId) changeAccessor.removeZone(viewZoneId);
        //     viewZoneId = changeAccessor.addZone({
        //         afterLineNumber: e.target.position.lineNumber,
        //         heightInLines: 6,
        //         domNode: domNode
        //     });
        // });
    });
}

function getTokenAtPosition(model, position) {
    const lineNumber = position.lineNumber;
    const text = model.getValueInRange({
        startLineNumber: lineNumber,
        endLineNumber: lineNumber + 1
    });
    const tokens = monaco.editor.tokenize(text, 'novel').shift();
    for (let i = 0; i < tokens.length - 1; i++) {
        tokens[i].length = tokens[i + 1].offset - tokens[i].offset;
    }
    tokens[tokens.length - 1].length =
        text.length - tokens[tokens.length - 1].offset;
    const tokenTexts = tokens.map(token =>
        text.slice(token.offset, token.offset + token.length)
    );

    let tokenAtPositionIndex = -1;
    let offset = 0;
    for (let i = 0; i < tokens.length; i++) {
        offset += tokens[i].offset + tokens[i].length;
        if (position.column <= offset) {
            tokenAtPositionIndex = i;
            break;
        }
    }

    return Object.assign({}, tokens[tokenAtPositionIndex], {
        text: tokenTexts[tokenAtPositionIndex]
    });
}

const colorsHash = {
    base03: '#002b36',
    base02: '#073642',
    base01: '#586e75',
    base00: '#657b83',
    base0: '#839496',
    base1: '#93a1a1',
    base2: '#eee8d5',
    base3: '#fdf6e3',
    yellow: '#b58900',
    orange: '#cb4b16',
    red: '#dc322f',
    magenta: '#d33682',
    violet: '#6c71c4',
    blue: '#268bd2',
    cyan: '#2aa198',
    green: '#859900'
};

const colors = {};
Object.keys(colorsHash).forEach(color => {
    colors[color] = colorsHash[color].replace('#', '');
});
