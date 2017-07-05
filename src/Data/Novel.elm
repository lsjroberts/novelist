module Data.Novel exposing (Novel, updateScene)

import Data.Scene exposing (Scene)
import Date exposing (Date)
import List.Extra


type alias Novel r =
    { r
        | scenes : List Scene
        , title : String
        , author : String
        , totalWordTarget : Maybe Int
        , deadline : Maybe Date
    }


updateScene : Int -> (Scene -> Scene) -> Novel r -> Novel r
updateScene id fn novel =
    { novel
        | scenes =
            novel.scenes
                |> List.Extra.updateIf (\scene -> scene.id == id) fn
    }
