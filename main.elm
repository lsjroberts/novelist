import Css exposing (..)
import List exposing (map)
import Html exposing (Html, div, span, section, article, header, h1, p, ul, li)
import Html.Attributes exposing (style, contenteditable, spellcheck)
import Html.App as App
import Html.Events exposing (onClick)

import Defaults exposing (..)

main : Program Never
main =
  App.beginnerProgram { model = model, view = view, update = update }


-- MODEL

type alias Model =
  { sceneTitle : String
  , sceneContent : List String
  , isWriting : Bool
  }

model : Model
model =
  { sceneTitle = defaultSceneTitle
  , sceneContent = defaultSceneContent
  , isWriting = False
  }


-- UPDATE

type Message = StartWriting | StopWriting

update : Message -> Model -> Model
update message model =
  case message of
    StartWriting ->
      { model | isWriting = True }
    StopWriting ->
      { model | isWriting = False }


-- VIEW

view : Model -> Html Message
view model =
  div [ styles [ padding (px 30) ], textStyle ]
    [ section
        [ menuStyle
        , leftMenuStyle
        , if model.isWriting then menuIsWritingStyle else noStyle
        , onClick StopWriting
        ]
        [ div
            [ menuGroupStyle ]
            [ span [ menuGroupTitleStyle ] [ Html.text "Modes" ]
            , ul [ menuGroupOptionsStyle ]
                [ li [ menuGroupItemStyle, menuGroupItemSelectedStyle ] [ Html.text "Distraction Free" ]
                , li [ menuGroupItemStyle ] [ Html.text "Conversation" ]
                , li [ menuGroupItemStyle ] [ Html.text "Editor" ]
                ]
            ]
        ]
    , section [ sceneStyle ]
        [ header []
            [ h1 [ sceneTitleStyle ] [ Html.text model.sceneTitle ]
            ]
        , article
            [ sceneContentStyle
            , if model.isWriting then sceneContentIsWritingStyle else noStyle
            , contenteditable True
            , spellcheck False
            , onClick StartWriting
            ]
            ( map
                (\t -> p [ sceneParagraphStyle ] [ Html.text t ])
                model.sceneContent
            )
        ]
    , section
        [ menuStyle
        , rightMenuStyle
        , if model.isWriting then menuIsWritingStyle else noStyle
        , onClick StopWriting
        ]
        [ Html.text "info" ]
    ]

styles =
  Css.asPairs >> style

noStyle =
  styles []

spacing =
  px 30

textStyle =
  styles
    [ fontFamilies [ "Avenir Next" ]
    , color (hex "333333")
    ]

menuStyle =
  styles
    [ position fixed
    , top spacing
    , width (pct 20)
    ]

leftMenuStyle =
  styles
    [ left spacing
    ]

rightMenuStyle =
  styles
    [ right spacing
    ]

menuIsWritingStyle =
  styles
    [ opacity (num 0.3)
    ]

menuGroupStyle =
  styles
    [ marginBottom spacing
    ]

menuGroupTitleStyle =
  styles
    [ fontSize (px 18)
    ]

menuGroupOptionsStyle =
  styles
    [ listStyle none
    , cursor pointer
    , margin zero
    , padding zero
    ]

menuGroupItemStyle =
  styles
    [ paddingLeft (em 1)
    ]

menuGroupItemSelectedStyle =
  styles
    [ fontWeight (int 600)
    ]

sceneStyle =
  styles
    [ marginLeft (pct 23)
    , width (pct 54)
    ]

sceneTitleStyle =
  styles
    [ fontFamilies [ "Cochin" ]
    , fontSize (px 48)
    , fontWeight (int 300)
    , textAlign center
    , color (hex "333333")
    ]

sceneContentStyle =
  styles
    [ outline zero
    , fontFamilies [ "Cochin" ]
    , fontSize (px 24)
    , lineHeight (px 31.2)
    , color (hex "333333")
    ]

sceneContentIsWritingStyle =
  styles
    []

sceneParagraphStyle =
  styles
    [ margin (px 0)
    , textIndent (em 1)
    ]
