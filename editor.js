require.config({ paths: { vs: "../node_modules/monaco-editor/min/vs" } });
require(["vs/editor/editor.main"], function() {
  fetch("/stubs/PrideAndPrejudice.novel/manuscript/1.txt")
    .then(response => console.log(response) || response.text())
    .then(contents => {
      console.log();
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
        "editorLineNumber.foreground": "#C7C7C4",
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
        lineNumbers: true,
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

      function thrones() {
        return [
          '	"We should start back," Gared urged as the woods began to grow dark around them. "The wildings are dead."',
          '	"Do the dead frighten you?" Ser Waymar Royce asked with just the hint of a smile.',
          '	Gared did not rise to the bait. He was an old man, past fifty, and he had seen the lordlings come and go. "Dead is dead," he said. "We have no business with the dead."',
          '	"Are they dead?" Royce asked softly. "What proof have we?"',
          '	"Will saw them," Gared said. "If he says they are dead, that’s proof enough for me."',
          '	Will had known they would drag him into the quarrel sooner or later. He wished it had been later rather than sooner. "My mother told me that dead men sing no songs," he put in.',
          '	"My wet nurse said the same thing, Will," Royce replied. "Never believe anything you hear at a woman’s tit. There are things to be learned even from the dead." His voice echoed, too loud in the twilit forest.',
          '	"We have a long rise before us," Gared pointed out. "Eight days, maybe nine. And night is falling."',
          '	Ser Waymar Royce glanced at the sky with disinterest. "It does that every day about this time. Are you unmanned by the dark, Gared?"',
          "	Will could see the tightness around Gared’s mouth, the barely suppressed anger in his eyes under the thick black hood of his cloak. Gared had spent forty years in the Night’s Watch, man and boy, and he was not accustomed to being made light of. Yet it was more than that. Under the wounded pride, Will could sense something else in the older man. You could taste it; a nervous tension that came perilously close to fear.",
          '	"We should start back," Gared urged as the woods began to grow dark around them. "The wildings are dead."',
          '	"Do the dead frighten you?" Ser Waymar Royce asked with just the hint of a smile.',
          '	Gared did not rise to the bait. He was an old man, past fifty, and he had seen the lordlings come and go. "Dead is dead," he said. "We have no business with the dead."',
          '	"Are they dead?" Royce asked softly. "What proof have we?"',
          '	"Will saw them," Gared said. "If he says they are dead, that’s proof enough for me."',
          '	Will had known they would drag him into the quarrel sooner or later. He wished it had been later rather than sooner. "My mother told me that dead men sing no songs," he put in.',
          '	"My wet nurse said the same thing, Will," Royce replied. "Never believe anything you hear at a woman’s tit. There are things to be learned even from the dead." His voice echoed, too loud in the twilit forest.',
          '	"We have a long rise before us," Gared pointed out. "Eight days, maybe nine. And night is falling."',
          '	Ser Waymar Royce glanced at the sky with disinterest. "It does that every day about this time. Are you unmanned by the dark, Gared?"',
          "	Will could see the tightness around Gared’s mouth, the barely suppressed anger in his eyes under the thick black hood of his cloak. Gared had spent forty years in the Night’s Watch, man and boy, and he was not accustomed to being made light of. Yet it was more than that. Under the wounded pride, Will could sense something else in the older man. You could taste it; a nervous tension that came perilously close to fear."
        ].join("\n");
      }
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
