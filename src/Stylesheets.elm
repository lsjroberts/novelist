port module Stylesheets exposing (..)

import Css.File exposing (CssFileStructure, CssCompilerProgram)
import Styles
import Editor.Styles


port files : CssFileStructure -> Cmd msg


fileStructure : CssFileStructure
fileStructure =
    Css.File.toFileStructure
        [ ( "app.css"
          , Css.File.compile
                [ Styles.css
                , Editor.Styles.css
                ]
          )
        ]


main : CssCompilerProgram
main =
    Css.File.compiler files fileStructure
