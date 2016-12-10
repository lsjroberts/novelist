module View exposing (root)

import Css exposing (..)
import Html exposing (Html, div)
import Types exposing (..)
import Scene.Types
import Scene.View
import Welcome.Types
import Welcome.View
import Styles exposing (..)


root : Model -> Html Msg
root model =
    div
        [ styles
            [ padding (px 30)
            , fontFamilies [ "Avenir Next" ]
            ]
        ]
        [ Scene.View.root model.scene |> Html.map SceneMsg ]



-- [ Welcome.View.root model.welcome |> Html.map WelcomeMsg ]
