#warn, all, msgBox
#noEnv
#singleInstance, force
sendMode, input
setWorkingDir, %A_ScriptDir%
detectHiddenWindows, on

#include %A_ScriptDir%\constants.ahk
#include %A_ScriptDir%\utils.ahk
#include %A_ScriptDir%\state.ahk
#include %A_ScriptDir%\memory.ahk
#include %A_ScriptDir%\macros.ahk

global mode, repeat, repeatSet, awaitsMotion
resetState()

setTimer, monitorGuitarPro, %LOOP_DELAY%

monitorGuitarPro()
{
    global WIN_TITLE
    global mode
    if (not winActive(WIN_TITLE))
    {
        resetState()
        return
    }

    ; Update mode if selection exists.
    selectionMode := getSelectionMode()
    if (selectionMode = "beats")
        setState({mode: "VISUAL"})
    else if (selectionMode = "bars")
        setState({mode: "V-BAR"})
    else if (mode = "VISUAL" or mode = "V-BAR")
        setState({mode: "NORMAL"})

    ; Update window title
    updateTitle()
}

#if WinActive(WIN_TITLE)
    escape::
    ^c::
        send, {escape}
        resetState()
        return

#if WinActive(WIN_TITLE) and mode != "INSERT"
    ; Number keys
    0::inputNumber(0)
    1::inputNumber(1)
    2::inputNumber(2)
    3::inputNumber(3)
    4::inputNumber(4)
    5::inputNumber(5)
    6::inputNumber(6)
    7::inputNumber(7)
    8::inputNumber(8)
    9::inputNumber(9)

    ; Cursor keys
    left::
    backspace::
    h::
        if (awaitsMotion = "d")
        {
            deleteBeats(-repeat)
        }
        else if (awaitsMotion = "c")
        {
            changeBeats(-repeat)
        }
        else if (awaitsMotion = "y")
        {
            yankBeats(-repeat)
        }
        else
        {
            moveCursor("left", repeat)
        }
        transitState()
        return
    down::
    enter::
    j::
        moveCursor("down", repeat)
        transitState()
        return
    up::
    k::
        moveCursor("up", repeat)
        transitState()
        return
    right::
    space::
    l::
        if (awaitsMotion = "d")
        {
            deleteBeats(repeat)
        }
        else if (awaitsMotion = "c")
        {
            changeBeats(repeat)
        }
        else if (awaitsMotion = "y")
        {
            yankBeats(repeat)
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
            transitState()
        }
        else if (awaitsMotion = "y")
        {
            yankBeatsToEnd(repeat)
            resetState()
        }
        else
        {
            goToEnd(repeat)
            transitState()
        }
        return
    b::
        if awaitsMotion in d,c
        {
            deleteBeatsToBeginning(repeat)
        }
        else if (awaitsMotion = "y")
        {
            yankBeatsToBeginning(repeat)
        }
        else
        {
            goToBeginning(repeat)
        }
        transitState()
        return
    w::
        if (awaitsMotion = ":")
        {
            save()
        }
        else if awaitsMotion in d,c
        {
            ; selectBeatsToBeginningOfNextBar(repeat)
            deleteBeatsToEnd(repeat)
        }
        else if (awaitsMotion = "y")
        {
            yankBeatsToEnd(repeat)
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
            deleteBeats()
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
            deleteBars()
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
            deleteBeats()
            resetState()
        }
        else if (mode = "V-BAR")
        {
            deleteBars()
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

    ; Undo/redo
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
        resetState({awaitsMotion: "r"})
        return
    +r::
        if (mode = "VISUAL")
            deleteBars()
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
        if (awaitsMotion = ":")
        {
            open()
            resetState()
        }
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
            clearBars(repeat)
            resetState({mode: "INSERT"})
        }
        else if (mode = "VISUAL")
        {
            deleteBeats()
            resetState({mode: "INSERT"})
        }
        else if (mode = "V-BAR")
        {
            deleteBars()
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
            deleteBars()
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
            deleteBeats()
            resetState({mode: "INSERT"})
        }
        else if (mode = "V-BAR")
        {
            deleteBars()
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

    +j::
        keyWait, shift
        joinBars(repeat)
        resetState()
        return

    ; Visual mode
    v::
        if (mode = "VISUAL")
        {
            deselect()
            resetState()
        }
        else if (mode = "V-BAR")
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
        if (mode = "V-BAR")
        {
            deselect()
            resetState()
        }
        else if (mode = "VISUAL")
        {
            resetState({mode: "V-BAR"})
        }
        else
        {
            selectBars(repeat)
            resetState({mode: "V-BAR"})
        }
        return

    ; Copy/paste
    y::
        if (awaitsMotion = "y")
        {
            yankBars(repeat)
            transitState()
        }
        else if (mode = "VISUAL")
        {
            yank()
            resetState()
        }
        else if (mode = "V-BAR")
        {
            yankBars()
            resetState()
        }
        else
        {
            setState({awaitsMotion: "y"})
        }
        return
    +y::
        yankBars(repeat)
        resetState()
        return
    ; p::
    ;     return
    +p::
        keyWait, shift
        if (awaitsMotion = "g")
        {
            putLeft("insert", repeat)
        }
        else
        {
            put("insert", repeat)
        }
        resetState()
        return

    ; Command-line prompt
    :::
        keyWait, shift
        setState({awaitsMotion: ":"})
        return

    ; New file (in command-line mode)
    n::
        if (awaitsMotion = ":")
        {
            new()
        }
        resetState()
        return

    ; Quit
    q::
        if (awaitsMotion = ":")
        {
            quit()
        }
        resetState()
        return
    +z::
        if (awaitsMotion = "Z")
        {
            quit(true)
            resetState()
        }
        else
        {
            setState({awaitsMotion: "Z"})
        }
        return
    +q::
        if (awaitsMotion = "Z")
        {
            quit(false)
        }
        resetState()
        return

    ; Mouse
    rbutton::
        selectToMouse()
        return
    mbutton::
        putToMouse()
        return
