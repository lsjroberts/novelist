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
            const word = model.getWordAtPosition(position);
            return {
                range: new monaco.Range(
                    position.lineNumber,
                    word.startColumn,
                    position.lineNumber,
                    word.endColumn
                ),
                contents: [
                    `**${word.word}**`,
                    { language: 'novel', value: 'A character' }
                ]
            };
        }
    });
});

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
