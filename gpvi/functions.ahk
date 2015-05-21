/**
 * Reset state to default and set values from given object.
 */
resetState(state:="")
{
    state := state ? state : {}
    global mode, repeat, awaitsMotion
    mode := state.hasKey("mode") ? state["mode"] : "NORMAL"
    repeat := state.hasKey("repeat") ? state["repeat"] : 1
    repeatSet := state.hasKey("repeat") ? state["repeat"] : false
    awaitsMotion := state.hasKey("awaitsMotion") ? state["awaitsMotion"] : ""
    updateTitle()
}

/**
 * Set state from the values of given object.
 */
setState(state:="")
{
    state := state ? state : {}
    global mode, repeat, awaitsMotion
    if (state.hasKey("mode"))
    {
        mode := state["mode"]
        updateTitle()
    }
    if (state.hasKey("repeat"))
        repeat := state["repeat"]
    if (state.hasKey("repeatSet"))
        repeatSet := state["repeatSet"]
    if (state.hasKey("awaitsMotion"))
        awaitsMotion := state["awaitsMotion"]
}

/**
 * Append given digit to repeat number.
 */
appendNumber(number)
{
    global repeat, repeatSet
    if (repeatSet)
        setState({repeatSet: true, repeat: repeat * 10 + number})
    else if (number > 0)
        setState({repeatSet: true, repeat: number})
}

/**
 * Switch mode based on current state.
 */
transitState()
{
    global awaitsMotion, mode
    state := {}
    if (awaitsMotion = "c")
        state["mode"] := "INSERT"
    else if (mode = "VISUAL")
        state["mode"] := "VISUAL"
    else if (mode = "V-BAR")
        state["mode"] := "V-BAR"
    resetState(state)
}

updateTitle()
{
    global WIN_TITLE, mode
    winGetTitle, winTitle, %WIN_TITLE%
    newTitle := regExReplace(winTitle, "^(Guitar Pro 5 - .*?)( - (NORMAL|VISUAL|V-BAR|INSERT))?$", "$1 - " . mode)
    winSetTitle, %WIN_TITLE%, , %newTitle%
}

moveCursor(direction, times:=1)
{
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    else if (mode = "V-BAR")
        send, {ctrl down}{shift down}
    send, {%direction% %times%}
    if (mode = "VISUAL")
        send, {shift up}
    else if (mode = "V-BAR")
        send, {ctrl up}{shift up}
}

goToEnd(times:=1)
{
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    else if (mode = "V-BAR")
        send, {shift down}
    loop, %times%
    {
        send, {right}{end}
    }
    if (mode = "VISUAL")
        send, {shift up}
    else if (mode = "V-BAR")
        send, {shift up}
}

goToBeginning(times:=1)
{
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    else if (mode = "V-BAR")
        send, {shift down}
    loop, %times%
    {
        send, {left}{home}
    }
    if (mode = "VISUAL")
        send, {shift up}
    else if (mode = "V-BAR")
        send, {shift up}
}

goToBeginningOfNextBar(times:=1)
{
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    else if (mode = "V-BAR")
        send, {shift down}
    loop, %times%
    {
        send, {end}{right}
    }
    if (mode = "VISUAL")
        send, {shift up}
    else if (mode = "V-BAR")
        send, {shift up}
}

goToBeatOfBar(number:=1)
{
    goToBeginning()
    if (number > 1)
    {
        moveCursor("right", (number - 1))
    }
}

goToAbsoluteBeat(number:=1)
{
    goToBeginningOfScore()
    if (number > 1)
    {
        moveCursor("right", (number - 1))
    }
}

goToBeginningOfScore()
{
    send, {ctrl down}{home}{ctrl up}
}

goToEndOfScore()
{
    send, {ctrl down}{end}{ctrl up}
    goToBeginning()
}

goToBar(number:=1)
{
    goToBeginningOfScore()
    goToBeginningOfNextBar(number - 1)
}

goToNextMarker(number:=1)
{
    send, {ctrl down}{tab %number%}{ctrl up}
}

goToPreviousMarker(number:=1)
{
    send, {shift down}{tab %number%}{shift up}
}

alternateWindow()
{
    global WIN_TITLE
    curId := WinActive(WIN_TITLE)
    winGet, id, list, %WIN_TITLE%
    if id > 1
    {
        winShow, ahk_id %id2%
        winActivate, ahk_id %id2%
    }
}

insertMarker()
{
    send, {shift down}{insert}{shift up}
}

listMarkers()
{
    ; send, {alt}ml
    send, {alt}{right 6}{down 2}{enter}
}

selectBeats(numberOfBeats:=1)
{
    direction := (numberOfBeats > 0) ? "right" : "left"
    if (numberOfBeats < 0) {
        send {left}
    }
    times := abs(numberOfBeats) - 1
    send {shift down}{up}{down}{%direction% %times%}{shift up}
}

selectBars(numberOfBars:=1)
{
    direction := (numberOfBars > 0) ? "right" : "left"
    times := abs(numberOfBars)
    send, {ctrl down}{shift down}
    loop, %times%
    {
        send, {%direction%}
        sleep, %BAR_SELECTION_DELAY%
    }
    send, {ctrl up}{shift up}
}

selectBeatsToEnd(times:=1)
{
    send, {shift down}{up}{down}
    goToEnd(times)
    send, {shift up}
}

selectBeatsToBeginning(times:=1)
{
    send, {left}{shift down}{up}{down}
    goToBeginning(times)
    send, {home}{shift up}
}

selectBeatsToBeginningOfNextBar(times:=1)
{
    send, {shift down}{up}{down}
    goToBeginningOfNextBar(times)
    send, {shift up}
}

selectToMouse()
{
    send {shift down}{LButton}{shift up}
}

deleteNotes(numberOfNotes:=1)
{
    loop, % abs(numberOfNotes)
    {
        if (numberOfNotes > 0)
        {
            send, {delete}{right}
        }
        else
        {
            send, {left}{delete}
        }
    }
}

deleteBeats(times:=1, cut:=false)
{
    delete := not cut ? "{delete}" : "{ctrl down}x{ctrl up}"
    if (abs(times) = 1)
    {
        if (times < 0)
        {
            send, {left}
        }
        send, {shift down}{up}{down}{shift up}%delete%
    }
    else
    {
        selectBeats(times)
        send, %delete%
    }
}

deleteBeatsToEnd(times:=1, cut:=false)
{
    delete := not cut ? "{delete}" : "{ctrl down}x{ctrl up}"
    selectBeatsToEnd(times)
    send, %delete%
    if (times > 1)
    {
        times -= 1
        send, {left %times%}
    }
}

deleteBeatsToBeginning(times:=1, cut:=false)
{
    delete := not cut ? "{delete}" : "{ctrl down}x{ctrl up}"
    selectBeatsToBeginning(times)
    send, %delete%
    if (times > 1)
    {
        times -= 1
        send, {left %times%}
    }
}

deleteBars(numberOfBars:=1)
{
    if (numberOfBars > 1)
    {
        selectBars(numberOfBars)
    }
    send, {ctrl down}x{ctrl up}
    sleep, %DIALOG_DELAY%
    send, {enter}
}

clearBars(numberOfBars:=1)
{
    selectBars(numberOfBars)
    send, {delete}
    if (numberOfBars > 1)
    {
        times := numberOfBars - 1
        send, {left %times%}
    }
}

changeBars(numberOfBars:=1)
{
    if (numberOfBars > 1)
        deleteBars(numberOfBars - 1)
    clearBars()
}

changeBeats(numberOfBeats:=1)
{
    if (numberOfBeats = 1)
    {
        replaceWithRest()
    }
    else
    {
        ; Inconsistency on the end of the bar
        send, {insert}{right}
        deleteBeats(numberOfBeats)
        send, {left}
    }
}

undo(times:=1)
{
    loop, %times%
    {
        send, {ctrl down}z{ctrl up}
    }
}

redo(times:=1)
{
    loop, %times%
    {
        send, {ctrl down}Z{ctrl up}
    }
}

paste()
{
    send, {ctrl down}v{ctrl up}
    sleep, %DIALOG_DELAY%
    send, {enter}
}

replaceWithRest()
{
    send, r
}

insertBeat()
{
    send, {insert}
}

insertBeatToBeginning()
{
    send, {home}{insert}
}

appendBeat()
{
    ; Could be better.
    send, {enter}
}

appendBeatToEnd()
{
    send, {end}{enter}
}

insertBar()
{
    send, {ctrl down}{insert}{ctrl up}
}

appendBar()
{
    ; Uses clipboard -- not optimal.
    insertBar()
    send, {right}
    deleteBeatsToEnd(1, true)
    send, {left}
    paste()
}

transposeUp(times:=1)
{
    loop, %times%
    {
        ; send, {alt}nuu{enter}
        send, {alt}{right 4}{down 19}{enter}
    }
}

transposeDown(times:=1)
{
    loop, %times%
    {
        send, {alt}{right 4}{down 20}{enter}
    }
}

deselect()
{
    send, {escape}
}
