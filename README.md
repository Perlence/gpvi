# Guitar Pro Vi

Guitar Pro vi is a set of Vi-like hotkeys for Guitar Pro 5. It was tested to work with Guitar Pro 5.1 and Guitar Pro 5.2.


## Insert mode

In Insert mode all hotkeys of Normal and Visual modes are disabled. You can interact with Guitar Pro 5 as you did it before. To quit Insert mode, press <kbd>Esc</kbd> or <kbd>Ctrl-C</kbd>.


## Normal mode

Legend:

- *N* - a number entered before the command
- *{motion}* - a cursor movement command
- *Nmove* - the text that is moved over with a *{motion}*

| Key | Action |
| --- | ------ |
| <kbd>Ctrl-6</kbd> | switch to alternate Guitar Pro 5 window |
| <kbd>Ctrl-A</kbd> | transpose note under cursor *N* semitones up |
| <kbd>Ctrl-C</kbd> | interrupt current command |
| <kbd>Ctrl-R</kbd> | redo changes which were undone with <kbd>u</kbd> *N* times |
| <kbd>Ctrl-X</kbd> | transpose note under cursor *N* semitones down |
| <kbd>Backspace</kbd> | same as <kbd>h</kbd> |
| <kbd>Enter</kbd> | same as <kbd>j</kbd> |
| <kbd>Space</kbd> | same as <kbd>l</kbd> |
| <kbd>0</kbd> | prepend to command to give a count |
| <kbd>1</kbd> | prepend to command to give a count |
| <kbd>2</kbd> | prepend to command to give a count |
| <kbd>3</kbd> | prepend to command to give a count |
| <kbd>4</kbd> | prepend to command to give a count |
| <kbd>5</kbd> | prepend to command to give a count |
| <kbd>6</kbd> | prepend to command to give a count |
| <kbd>7</kbd> | prepend to command to give a count |
| <kbd>8</kbd> | prepend to command to give a count |
| <kbd>9</kbd> | prepend to command to give a count |
| <kbd>:</kbd> | start entering an Ex command |
| <kbd>A</kbd> | insert a beat in the end of the bar and enter Insert mode |
| <kbd>C</kbd> | clear the beats under the cursor until the end of the bar and *N-1* more bar and enter Insert mode |
| <kbd>D</kbd> | delete the beats under the cursor until the end of the bar and *N-1* more bar |
| <kbd>G</kbd> | cursor to bar *N*, default last bar |
| <kbd>I</kbd> | insert a beat in the beginning of the bar and enter Insert mode |
| <kbd>M</kbd> | list section markers |
| <kbd>O</kbd> | begin a new bar after the cursor and enter Insert mode |
| <kbd>P</kbd> | put beats/bars before the cursor *N* times |
| <kbd>S</kbd> | clear *N* bars and enter Insert mode |
| <kbd>V</kbd> | start bar-wise Visual mode |
| <kbd>X</kbd> | delete *N* notes before the cursor |
| <kbd>ZQ</kbd> | exit current file always |
| <kbd>ZZ</kbd> | save current file and exit |
| <kbd>[</kbd><kbd>[</kbd>, <kbd>[</kbd><kbd>]</kbd> | cursor *N* sections backward |
| <kbd>]</kbd><kbd>]</kbd>, <kbd>]</kbd><kbd>[</kbd> | cursor *N* sections forward |
| <kbd>a</kbd> | insert a beat after cursor and enter Insert mode |
| <kbd>b</kbd> | cursor forward to beginning of the bar *N* |
| <kbd>c</kbd><kbd>c</kbd> | clear *N* bars and enter Insert mode |
| <kbd>c</kbd><kbd>{motion}</kbd> | delete *Nmove* beats/bars and enter Insert mode |
| <kbd>d</kbd><kbd>d</kbd> | delete *N* bars |
| <kbd>d</kbd><kbd>{motion}</kbd> | delete *Nmove* beats/bars |
| <kbd>e</kbd> | cursor forward to end of the bar *N* |
| <kbd>g</kbd><kbd>g</kbd> | cursor to bar *N*, default first bar |
| <kbd>g</kbd><kbd>o</kbd> | cursor to beat *N*, starting from the first beat of the first bar |
| <kbd>g</kbd><kbd>P</kbd> | put beats/bars before the cursor *N* times and move cursor right one beat |
| <kbd>h</kbd> | cursor *N* beats to the left |
| <kbd>i</kbd> | insert a beat before cursor and enter Insert mode |
| <kbd>j</kbd> | cursor *N* lines downward |
| <kbd>k</kbd> | cursor *N* lines upward |
| <kbd>l</kbd> | cursor *N* beats to the right |
| <kbd>m</kbd> | insert section marker |
| <kbd>o</kbd> | begin a new bar before the cursor and enter Insert mode |
| <kbd>r</kbd> | replace note with *N* |
| <kbd>s</kbd> | replace *N* beats in the current bar with a rest |
| <kbd>u</kbd> | undo changes *N* times |
| <kbd>v</kbd> | start beat-wise Visual mode |
| <kbd>w</kbd> | cursor *N* bars forward |
| <kbd>x</kbd> | delete *N* notes under and after the cursor |
| <kbd>y</kbd><kbd>y</kbd>, <kbd>Y</kbd> | yank *N* bars |
| <kbd>y</kbd><kbd>{motion}</kbd> | yank *Nmove* beats/bars |
| <kbd>&#124;</kbd> | cursor to *N* beat of the current bar |
| <kbd>←</kbd> | same as <kbd>h</kbd> |
| <kbd>↑</kbd> | same as <kbd>k</kbd> |
| <kbd>↓</kbd> | same as <kbd>j</kbd> |
| <kbd>→</kbd> | same as <kbd>l</kbd> |
| <kbd>LeftMouse</kbd> | move cursor to the mouse click position |
| <kbd>MiddleMouse</kbd> | same as <kbd>g</kbd><kbd>P</kbd> at the mouse click position |


## Visual mode

| Key | Action |
| --- | ------ |
| <kbd>Ctrl-C</kbd>, <kbd>Esc</kbd> | stop Visual mode |
| <kbd>C</kbd> | delete the highlighted bars |
| <kbd>D</kbd> | delete the highlighted bars |
| <kbd>R</kbd> | delete the highlighted bars |
| <kbd>S</kbd> | delete the highlighted bars |
| <kbd>V</kbd> | make Visual mode bar-wise or stop Visual mode |
| <kbd>Y</kbd> | yank the highlighted bars |
| <kbd>X</kbd> | delete the highlighted bars |
| <kbd>c</kbd> | delete highlighted area and start insert |
| <kbd>d</kbd> | delete the highlighted area |
| <kbd>s</kbd> | delete the highlighted area |
| <kbd>v</kbd> | make Visual mode beat-wise or stop Visual mode |
| <kbd>y</kbd> | yank the highlighted area |
| <kbd>x</kbd> | delete the highlighted area |


## Ex commands

Ex commands are maximally simplified to one letter commands. The command will execute instantaneously as the letter is pressed, no need to press <kbd>Enter</kbd> afterwards.

| Command | Action |
| ------- | ------ |
| <kbd>:</kbd><kbd>n</kbd> | new file |
| <kbd>:</kbd><kbd>w</kbd> | save file |
| <kbd>:</kbd><kbd>o</kbd> | open file |
| <kbd>:</kbd><kbd>q</kbd> | quit Guitar Pro 5 |
