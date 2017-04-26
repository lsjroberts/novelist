port module Stylesheets exposing (..)

import Css.File exposing (CssFileStructure, CssCompilerProgram)
import Styles
import Binder.Styles
import Editor.Styles
import Inspector.Styles
import Panel.Styles


port files : CssFileStructure -> Cmd msg


fileStructure : CssFileStructure
fileStructure =
    Css.File.toFileStructure
        [ ( "app.css"
          , Css.File.compile
                [ Styles.css
                , Binder.Styles.css
                , Editor.Styles.css
                , Inspector.Styles.css
                , Panel.Styles.css
                ]
          )
        ]


main : CssCompilerProgram
main =
    Css.File.compiler files fileStructure
