/**
 * Reset state to default and set values from given object.
 */
resetState(state:="")
{
    state := state ? state : {}
    global mode, repeat, awaitsMotion, replace
    mode := state.hasKey("mode") ? state["mode"] : "NORMAL"
    repeat := state.hasKey("repeat") ? state["repeat"] : 1
    repeatSet := state.hasKey("repeat") ? state["repeat"] : false
    awaitsMotion := state.hasKey("awaitsMotion") ? state["awaitsMotion"] : ""
    replace := state.hasKey("replace") ? state["replace"] : ""
    updateTitle()
}

/**
 * Set state from the values of given object.
 */
setState(state:="")
{
    state := state ? state : {}
    global mode, repeat, awaitsMotion, replace
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
    if (state.hasKey("replace"))
        replace := state["replace"]
}

/**
 * Append given digit to repeat number or send number key if in replace
 * mode.
 */
inputNumber(number)
{
    global awaitsMotion, repeat, repeatSet
    if (awaitsMotion = "r")
    {
        send, %number%
        if (number = 0 or number > 2)
            resetState()
    }
    else
    {
        if (repeatSet)
            setState({repeatSet: true, repeat: repeat * 10 + number})
        else if (number > 0)
            setState({repeatSet: true, repeat: number})
    }
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
    else if (awaitsMotion = "y")
        state["mode"] := "NORMAL"
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
