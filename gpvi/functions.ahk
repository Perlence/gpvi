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
    else if (mode = "V-LINE")
        state["mode"] := "V-LINE"
    resetState(state)
}

updateTitle()
{
    global WIN_TITLE, mode
    winGetTitle, winTitle, %WIN_TITLE%
    newTitle := regExReplace(winTitle, "^(Guitar Pro 5 - .*?)( - (NORMAL|VISUAL|V-LINE|INSERT))?$", "$1 - " . mode)
    winSetTitle, %WIN_TITLE%, , %newTitle%
}

moveCursor(direction, times)
{
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    else if (mode = "V-LINE")
        send, {ctrl down}{shift down}
    send, {%direction% %times%}
    if (mode = "VISUAL")
        send, {shift up}
    else if (mode = "V-LINE")
        send, {ctrl up}{shift up}
}

goToEnd(times)
{
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    else if (mode = "V-LINE")
        send, {shift down}
    loop, %times%
    {
        send, {right}{end}
    }
    if (mode = "VISUAL")
        send, {shift up}
    else if (mode = "V-LINE")
        send, {shift up}
}

goToBeginning(times)
{
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    else if (mode = "V-LINE")
        send, {shift down}
    loop, %times%
    {
        send, {left}{home}
    }
    if (mode = "VISUAL")
        send, {shift up}
    else if (mode = "V-LINE")
        send, {shift up}
}

goToBeginningOfNextBar(times)
{
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    else if (mode = "V-LINE")
        send, {shift down}
    loop, %times%
    {
        send, {end}{right}
    }
    if (mode = "VISUAL")
        send, {shift up}
    else if (mode = "V-LINE")
        send, {shift up}
}

goToBeatOfBar(number)
{
    goToBeginning(1)
    if (number > 1)
    {
        moveCursor("right", (number - 1))
    }
}

goToAbsoluteBeat(number)
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
    goToBeginning(1)
}

goToBar(number)
{
    goToBeginningOfScore()
    goToBeginningOfNextBar(number - 1)
}

goToNextMarker(number)
{
    send, {ctrl down}{tab %number%}{ctrl up}
}

goToPreviousMarker(number)
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

selectBeats(numberOfBeats)
{
    direction := (numberOfBeats > 0) ? "right" : "left"
    if (numberOfBeats < 0) {
        send {left}
    }
    times := abs(numberOfBeats) - 1
    send {shift down}{up}{down}{%direction% %times%}{shift up}
}

selectBars(numberOfBars)
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

selectBeatsToEnd(times)
{
    send, {shift down}{up}{down}
    goToEnd(times)
    send, {shift up}
}

selectBeatsToBeginning(times)
{
    send, {left}{shift down}{up}{down}
    goToBeginning(times)
    send, {home}{shift up}
}

selectBeatsToBeginningOfNextBar(times)
{
    send, {shift down}{up}{down}
    goToBeginningOfNextBar(times)
    send, {shift up}
}

deleteNotes(numberOfNotes)
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

deleteBeats(times, cut:=false)
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

deleteBeatsToEnd(times, cut:=false)
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

deleteBeatsToBeginning(times, cut:=false)
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

deleteBars(numberOfBars)
{
    if (numberOfBars > 1)
    {
        selectBars(numberOfBars)
    }
    send, {ctrl down}x{ctrl up}
    sleep, %DIALOG_DELAY%
    send, {enter}
}

clearBars(numberOfBars)
{
    selectBars(numberOfBars)
    send, {delete}
    if (numberOfBars > 1)
    {
        times := numberOfBars - 1
        send, {left %times%}
    }
}

changeBars(numberOfBars)
{
    if (numberOfBars > 1)
        deleteBars(numberOfBars - 1)
    clearBars(1)
}

changeBeats(numberOfBeats)
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

undo(times)
{
    loop, %times%
    {
        send, {ctrl down}z{ctrl up}
    }
}

redo(times)
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

transposeUp(times)
{
    loop, %times%
    {
        ; send, {alt}nuu{enter}
        send, {alt}{right 4}{down 19}{enter}
    }
}

transposeDown(times)
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
