Mode = "NORMAL"
Repetition := 1
AwaitsMotion = ""

#If WinActive("Guitar Pro 5")
    Escape::
        Send {Escape}
        Mode = "NORMAL"
        Repetition := 1
        AwaitsMotion = ""
        Return

    If Mode = "NORMAL"
    {
        ; Number keys
        1::
            Repetition := 1
            Return
        2::
            Repetition := 2
            Return
        3::
            Repetition := 3
            Return
        4::
            Repetition := 4
            Return
        5::
            Repetition := 5
            Return
        6::
            Repetition := 6
            Return
        7::
            Repetition := 7
            Return
        8::
            Repetition := 8
            Return
        9::
            Repetition := 9
            Return

        ; Cursor keys
        h::
            If AwaitsMotion = "d"
            {
                Send {Left}{Shift Down}
                If Repetition = 1
                {
                    Send {Down}{Delete}{Shift Up}{Up}
                }
                Else
                {
                    Repetition := Repetition - 1
                    Send {Left %Repetition%}{Delete}{Shift Up}
                }
            }
            Else
            {
                Send {Left %Repetition%}
            }
            Repetition := 1
            AwaitsMotion = ""
            Return
        j::
            Send {Down %Repetition%}
            Repetition := 1
            AwaitsMotion = ""
            Return
        k::
            Send {Up %Repetition%}
            Repetition := 1
            AwaitsMotion = ""
            Return
        l::
            If AwaitsMotion = "d"
            {
                Send {Shift Down}
                If Repetition = 1
                {
                    Send {Down}{Delete}{Shift Up}{Up}
                }
                Else
                {
                    Repetition := Repetition - 1
                    Send {Right %Repetition%}{Delete}{Shift Up}
                }
            }
            Else
            {
                Send {Right %Repetition%}
            }
            Repetition := 1
            AwaitsMotion = ""
            Return

        ; Bar navigation
        e::
            If AwaitsMotion = "d"
            {
                Send {Shift Down}
                Loop %Repetition%
                {
                    Send {Right}{End}
                }
                Send {Delete}{Shift Up}
            }
            Else
            {
                Loop %Repetition%
                {
                    Send {Right}{End}
                }
            }
            Repetition := 1
            AwaitsMotion = ""
            Return
        b::
            If AwaitsMotion = "d"
            {
                Send {Left}{Shift Down}
                Repetition := Repetition - 1
                Loop %Repetition%
                {
                    Send {Home}{Left}
                }
                Send {Home}{Delete}{Shift Up}
            }
            Else
            {
                Loop %Repetition%
                {
                    Send {Ctrl Down}{Left}{Ctrl Up}{Home}
                }
            }
            Repetition := 1
            AwaitsMotion = ""
            Return
        w::
            ; TODO: Implement "d" motion
            Loop %Repetition%
            {
                Send {Ctrl Down}{Right}{Ctrl Up}
            }
            Repetition := 1
            AwaitsMotion = ""
            Return

        ; Deletion keys
        d::
            If AwaitsMotion = "d"
            {
                Send {Ctrl Down}{Shift Down}
                Loop  %Repetition%
                {
                    Send {Right Down}
                    Sleep 10
                    Send {Right Up}
                }
                Send {Shift Up}x{Ctrl Up}{Enter}
                Repetition := 1
                AwaitsMotion = ""
            }
            Else
            {
                AwaitsMotion = "d"
            }
            Return
        x::
            If Repetition = 1
                Send {Delete}
            Else
            {
                Loop % Repetition - 1
                {
                    Send {Delete}{Right}
                }
                Send {Delete}
            }
            Repetition := 1
            Return

        ; Unde/Redo keys
        u::
            Loop %Repetition%
            {
                Send {Ctrl Down}z{Ctrl Up}
            }
            Repetition := 1
            Return
        ^r::
            Loop %Repetition%
            {
                Send {Ctrl Down}Z{Ctrl Up}
            }
            Repetition := 1
            Return
    }
