require.config({ paths: { vs: "../node_modules/monaco-editor/min/vs" } });
require(["vs/editor/editor.main"], function() {
  const url = new URL(document.location);
  const file = url.searchParams.get("file");
  fetch(file)
    .then(response => console.log(response) || response.text())
    .then(contents => {
      // Register a new language
      monaco.languages.register({ id: "novel" });

      // Register a tokens provider for the language
      monaco.languages.setMonarchTokensProvider("novel", {
        tokenizer: {
          root: [
            ['["“][^"”]+["”]?', "speech"],
            [
              /[A-Z]\w*('s)?/,
              {
                cases: {
                  "@keywords": { token: "character" }
                }
              }
            ]
          ]
        },
        keywords: ["Gared", "Ser Waymar Royce", "Royce", "Will"]
      });

      monaco.languages.setLanguageConfiguration("novel", {
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
        "editor.background": "#FFFFFF",
        "editor.foreground": "#333333",
        "editorHoverWidget.background": "#F7F7F7",
        "editorLineNumber.foreground": "#F0F0F0",
        "editor.lineHighlightBackground": "#F2F2F2",
        "editor.lineHighlightBorder": "#00000000"
      };

      const defaultThemeRules = [
        { token: "source", foreground: colors.base02 }
      ];
      const speechThemeRules = defaultThemeRules.concat([
        // { token: "character", foreground: "B58900" },
        // { token: "speech", foreground: "2AA198" }
        // { token: "character", foreground: "3377B9" },
        // { token: "character", foreground: "B14FA2" },
        // { token: "speech", foreground: "40831E" }
        { token: "speech", foreground: "B14FA2" }
      ]);

      // Define a new theme that constains only rules that match this language
      monaco.editor.defineTheme("novelist", {
        base: "vs",
        colors: defaultThemeColors,
        inherit: false,
        rules: defaultThemeRules
      });

      monaco.editor.defineTheme("novelist-speech", {
        base: "vs",
        colors: defaultThemeColors,
        inherit: false,
        rules: speechThemeRules
      });

      monaco.languages.registerHoverProvider("novel", {
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
              { language: "novel", value: "A character" }
            ]
          };
        }
      });

      var editor = monaco.editor.create(document.getElementById("container"), {
        automaticLayout: true, // TODO: this occurs every 100ms, do it better
        theme: "novelist-speech",
        language: "novel",
        // value: thrones(),
        value: contents,
        wordWrap: "on",
        // wordWrap: "wordWrapColumn",
        // wordWrapColumn: 80,
        lineNumbers: false,
        fontFamily: "Cochin",
        fontSize: 18,
        lineHeight: 18 * 1.8,
        minimap: {
          renderCharacters: false
        }
      });

      editor.addAction({
        id: "novelist-character-add",
        label: "Character: Add new character",
        run: () => {
          console.log("creating a new character");
        }
      });

      var viewZoneId = null;

      editor.onMouseDown(e => {
        return;

        editor.changeViewZones(function(changeAccessor) {
          var domNode = document.createElement("div");
          domNode.style.background = "#F1F1F1";

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
    });
});

const colorsHash = {
  base03: "#002b36",
  base02: "#073642",
  base01: "#586e75",
  base00: "#657b83",
  base0: "#839496",
  base1: "#93a1a1",
  base2: "#eee8d5",
  base3: "#fdf6e3",
  yellow: "#b58900",
  orange: "#cb4b16",
  red: "#dc322f",
  magenta: "#d33682",
  violet: "#6c71c4",
  blue: "#268bd2",
  cyan: "#2aa198",
  green: "#859900"
};

const colors = {};
Object.keys(colorsHash).forEach(color => {
  colors[color] = colorsHash[color].replace("#", "");
});
