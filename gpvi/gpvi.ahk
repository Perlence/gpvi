#noEnv
#singleInstance, force
sendMode, input
setWorkingDir, %A_ScriptDir%

#include %A_ScriptDir%\constants.ahk
#include %A_ScriptDir%\functions.ahk

global mode, repeat, repeatSet, awaitsMotion
resetState()

loop
{
    winWaitActive, Guitar Pro 5
    updateTitle()
    sleep, 1000
}

#if WinActive("Guitar Pro 5")
    escape::
        send, {escape}
        resetState()
        return
    ^c::
        send, {escape}
        resetState()
        return

#if WinActive("Guitar Pro 5") and mode != "INSERT"
    ; Number keys
    0::appendNumber(0)
    1::appendNumber(1)
    2::appendNumber(2)
    3::appendNumber(3)
    4::appendNumber(4)
    5::appendNumber(5)
    6::appendNumber(6)
    7::appendNumber(7)
    8::appendNumber(8)
    9::appendNumber(9)

    ; Cursor keys
    h::
        if (awaitsMotion = "d")
        {
            deleteBeats(-repeat)
        }
        else if (awaitsMotion = "c")
        {
            changeBeats(-repeat)
        }
        else
        {
            moveCursor("left", repeat)
        }
        transitState()
        return
    j::
        moveCursor("down", repeat)
        transitState()
        return
    k::
        moveCursor("up", repeat)
        transitState()
        return
    l::
        if (awaitsMotion = "d")
        {
            deleteBeats(repeat)
        }
        else if (awaitsMotion = "c")
        {
            changeBeats(repeat)
        }
        else
        {
            moveCursor("right", repeat)
        }
        transitState()
        return

    ; Bar navigation
    e::
        if awaitsMotion in d,c
        {
            deleteBeatsToEnd(repeat)
        }
        else
        {
            goToEnd(repeat)
        }
        transitState()
        return
    b::
        if awaitsMotion in d,c
        {
            deleteBeatsToBeginning(repeat)
        }
        else
        {
            goToBeginning(repeat)
        }
        transitState()
        return
    w::
        if awaitsMotion in d,c
        {
            ; selectBeatsToBeginningOfNextBar(repeat)
            deleteBeatsToEnd(repeat)
        }
        else
        {
            goToBeginningOfNextBar(repeat)
        }
        transitState()
        return
    |::
        goToBeatOfBar(repeat)
        resetState()
        return

    ; Score navigation
    g::
        if (awaitsMotion = "g")
        {
            if (repeat = 1)
            {
                goToBeginningOfScore()
            }
            else
            {
                goToBar(repeat)
            }
            resetState()
        }
        else
        {
            setState({awaitsMotion: "g"})
        }
        return
    +g::
        if (not repeatSet)
        {
            goToEndOfScore()
        }
        else
        {
            goToBar(repeat)
        }
        resetState()
        return
    [::
        if (awaitsMotion = "]")
        {
            goToNextMarker(repeat)
            resetState()
        }
        else if (awaitsMotion = "[")
        {
            goToPreviousMarker(repeat)
            resetState()
        }
        else
        {
            setState({awaitsMotion: "["})
        }
        return
    ]::
        if (awaitsMotion = "]")
        {
            goToNextMarker(repeat)
            resetState()
        }
        else if (awaitsMotion = "[")
        {
            goToPreviousMarker(repeat)
            resetState()
        }
        else
        {
            setState({awaitsMotion: "]"})
        }
        return
    m::
        insertMarker()
        resetState()
        return
    +m::
        keyWait, shift
        listMarkers()
        resetState()
        return

    ; Window navigation
    ^6::
        alternateWindow()
        resetState()
        return

    ; Deletion
    x::
        if (mode = "VISUAL")
        {
            deleteBeats(1)
        }
        else
        {
            deleteNotes(repeat)
        }
        resetState()
        return
    +x::
        keyWait, shift
        if (mode = "VISUAL")
        {
            deleteBars(1)
        }
        else
        {
            deleteNotes(-repeat)
        }
        resetState()
        return
    d::
        if (awaitsMotion = "d")
        {
            deleteBars(repeat)
            transitState()
        }
        else if (mode = "VISUAL")
        {
            deleteBeats(1)
            resetState()
        }
        else if (mode = "V-LINE")
        {
            deleteBars(1)
            resetState()
        }
        else
        {
            setState({awaitsMotion: "d"})
        }
        return
    +d::
        keyWait, shift
        ; Does not return to the same beat if repeat > 1
        deleteBeatsToEnd(repeat)
        resetState()
        return

    ; Undo/redo keys
    u::
        undo(repeat)
        resetState()
        return
    ^r::
        keyWait, ctrl
        redo(repeat)
        resetState()
        return

    ; Replace, insert, and append
    r::
        resetState({mode: "INSERT"})
        return
    i::
        insertBeat()
        resetState({mode: "INSERT"})
        return
    +i::
        keyWait, shift
        insertBeatToBeginning()
        resetState({mode: "INSERT"})
        return
    a::
        appendBeat()
        resetState({mode: "INSERT"})
        return
    +a::
        keyWait, shift
        appendBeatToEnd()
        resetState({mode: "INSERT"})
        return
    o::
        if (awaitsMotion = "g")
        {
            goToAbsoluteBeat(repeat)
            resetState()
        }
        else
        {
            appendBar()
            resetState({mode: "INSERT"})
        }
        return
    +o::
        keyWait, shift
        insertBar()
        resetState({mode: "INSERT"})
        return
    ^a::
        keyWait, ctrl
        transposeUp(repeat)
        resetState()
        return
    ^x::
        keyWait, ctrl
        transposeDown(repeat)
        resetState()
        return

    ; Substitution and change
    c::
        if (awaitsMotion = "c")
        {
            changeBars(repeat)
            resetState({mode: "INSERT"})
        }
        else if (mode = "VISUAL")
        {
            deleteBeats(1)
            resetState({mode: "INSERT"})
        }
        else if (mode = "V-LINE")
        {
            deleteBars(1)
            insertBar()
            resetState({mode: "INSERT"})
        }
        else
        {
            setState({awaitsMotion: "c"})
        }
        return
    +c::
        keyWait, shift
        if (mode = "VISUAL")
        {
            deleteBars(1)
            insertBar()
            resetState({mode: "INSERT"})
        }
        else
        {
            deleteBeatsToEnd(repeat)
            resetState({mode: "INSERT"})
        }
        return
    s::
        if (mode = "VISUAL")
        {
            deleteBeats(1)
            resetState({mode: "INSERT"})
        }
        else if (mode = "V-LINE")
        {
            deleteBars(1)
            insertBar()
            resetState({mode: "INSERT"})
        }
        else
        {
            changeBeats(repeat)
        }
        resetState({mode: "INSERT"})
        return
    +s::
        keyWait, shift
        clearBars(repeat)
        resetState({mode: "INSERT"})
        return

    ; Visual mode
    v::
        if (mode = "VISUAL")
        {
            deselect()
            resetState()
        }
        else if (mode = "V-LINE")
        {
            resetState({mode: "VISUAL"})
        }
        else
        {
            selectBeats(repeat)
            resetState({mode: "VISUAL"})
        }
        return
    +v::
        keyWait, shift
        if (mode = "V-LINE")
        {
            deselect()
            resetState()
        }
        else if (mode = "VISUAL")
        {
            resetState({mode: "V-LINE"})
        }
        else
        {
            selectBars(repeat)
            resetState({mode: "V-LINE"})
        }
        return