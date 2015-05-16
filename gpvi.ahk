Mode := "NORMAL"
Repeat := 1
AwaitsMotion := ""

#If WinActive("Guitar Pro 5")
    Escape::
        Send {Escape}
        Mode := "NORMAL"
        Repeat := 1
        AwaitsMotion := ""
        Return

    #If WinActive("Guitar Pro 5") and Mode == "NORMAL"
        ; Number keys
        1::Repeat := 1
        2::Repeat := 2
        3::Repeat := 3
        4::Repeat := 4
        5::Repeat := 5
        6::Repeat := 6
        7::Repeat := 7
        8::Repeat := 8
        9::Repeat := 9

        ; Cursor keys
        h::
            If (AwaitsMotion = "d") {
                Send {Left}{Shift Down}
                If (Repeat = 1) {
                    Send {Down}{Up}{Delete}{Shift Up}
                } Else {
                    Repeat -= 1
                    Send {Left %Repeat%}{Delete}{Shift Up}
                }
            } Else {
                Send {Left %Repeat%}
            }
            Repeat := 1
            AwaitsMotion := ""
            Return
        j::
            Send {Down %Repeat%}
            Repeat := 1
            AwaitsMotion := ""
            Return
        k::
            Send {Up %Repeat%}
            Repeat := 1
            AwaitsMotion := ""
            Return
        l::
            If (AwaitsMotion = "d") {
                If (Repeat = 1) {
                    ; Delete beat
                    Send {Ctrl Down}{Delete}{Ctrl Up}
                } Else {
                    Repeat -= 1
                    Send {Shift Down}{Right %Repeat%}{Delete}{Shift Up}
                }
            } Else {
                Send {Right %Repeat%}
            }
            Repeat := 1
            AwaitsMotion := ""
            Return

        ; Bar navigation
        e::
            If (AwaitsMotion = "d") {
                Send {Shift Down}
                Loop %Repeat% {
                    Send {Right}{End}
                }
                Send {Shift Up}{Delete}
            } Else {
                Loop %Repeat% {
                    Send {Right}{End}
                }
            }
            Repeat := 1
            AwaitsMotion := ""
            Return
        b::
            If (AwaitsMotion = "d") {
                Send {Left}{Shift Down}
                Repeat -= 1
                Loop %Repeat% {
                    Send {Home}{Left}
                }
                Send {Home}{Delete}{Shift Up}
            } Else {
                Loop %Repeat% {
                    Send {Left}{Home}
                }
            }
            Repeat := 1
            AwaitsMotion := ""
            Return
        w::
            ; TODO: Implement "d" motion
            Loop %Repeat% {
                Send {Ctrl Down}{Right}{Ctrl Up}
            }
            Repeat := 1
            AwaitsMotion := ""
            Return

        ; Deletion keys
        x::
            Loop %Repeat% {
                Send {Delete}{Right}
            }
            Repeat := 1
            Return
        +x::
            Loop %Repeat% {
                Send {Left}{Delete}
            }
            Repeat := 1
            Return
        d::
            If (AwaitsMotion = "d") {
                Send {Ctrl Down}{Shift Down}
                Loop %Repeat% {
                    Send {Right Down}
                    Sleep 10
                    Send {Right Up}
                }
                Send {Shift Up}x{Ctrl Up}{Enter}
                Repeat := 1
                AwaitsMotion := ""
            } Else {
                AwaitsMotion := "d"
            }
            Return
        +d::
            ; Does not return to the same beat if Repeat > 1
            Send {Shift Down}
            Loop %Repeat% {
                Send {Right}{End}
            }
            Send {Shift Up}{Delete}
            Repeat := 1
            AwaitsMotion := ""
            Return

        ; Undo/Redo keys
        u::
            Loop %Repeat% {
                Send {Ctrl Down}z{Ctrl Up}
            }
            Repeat := 1
            Return
        ^r::
            Loop %Repeat% {
                Send {Ctrl Down}Z{Ctrl Up}
            }
            Repeat := 1
            Return

        i::
            Mode := "INSERT"
            Send {Insert}
            Return
        +i::
            Mode := "INSERT"
            Send {Home}{Insert}
            Return
        a::
            Mode := "INSERT"
            Send {Right}
            Return
        +a::
            Mode := "INSERT"
            Send {End}{Right}
            Return
        ; c::
        ;     Return
        ; +c::
        ;     Return
        s::
            Mode := "INSERT"
            If (Repeat = 1) {
                Send {Ctrl Down}{Delete}{Ctrl Up}{Insert}
            } Else {
                ; Inconsistency on the end of the bar
                Send {Insert}{Right}{Shift Down}
                Repeat -= 1
                Loop %Repeat% {
                    Send {Right Down}
                    Sleep 10
                    Send {Right Up}
                }
                Send {Shift Up}{Delete}{Left}
            }
            Return
