module StyleSheet.Types exposing (..)

import Style


type alias Palette =
    { standard : Style.Property
    , editor : Style.Property
    }


type Class
    = Base
