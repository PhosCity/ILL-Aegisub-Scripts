// Imports
#import "@preview/showybox:2.0.3": showybox
// ------------------------------------------------------------------------------

// Initial setup
#set par(justify: true)
#set page(numbering: "01", number-align: center)

#set heading(numbering: "1.1.")

#show link: it => {
  text(blue, it)
}

#show ref: it => {
  text(blue, it)
}

#show table.cell.where(y: 0): strong
// ------------------------------------------------------------------------------

// Custom Functions
#let warning(body) = {
  showybox(frame: (
    border-color: red.darken(40%),
    body-color: red.lighten(80%),
    thickness: (left: 2pt),
    radius: 0pt,
  ))[
    *Warning*

    #body
  ]
}

#let note(body) = {
  showybox(frame: (
    border-color: gray.darken(40%),
    body-color: gray.lighten(80%),
    thickness: (left: 2pt),
    radius: 0pt,
  ))[
    *Note*

    #body
  ]
}

#let code(body) = {
  showybox(frame: (
    border-color: gray.darken(40%),
    body-color: gray.lighten(80%),
    radius: 0pt,
  ))[
    #body
  ]
}

#let argument_table(elements) = {
  table(columns: 4,
    align: horizon,
    inset: 10pt,
    fill: (_, y) => if y == 0 {
      gray.lighten(70%)
    },
    table.header([Argument], [Description], [Type], [Default]),
    ..elements)
}

#let return_table(elements) = {
  table(columns: 3,
    align: horizon,
    inset: 10pt,
    fill: (_, y) => if y == 0 {
      gray.lighten(70%)
    },
    table.header([Returns], [Description], [Type]),
    ..elements)
}

#let argument_table_empty() = {
  table(
    columns: 1,
    align: horizon,
    inset: 10pt,
    fill: (_, y) => if y == 0 {
      gray.lighten(70%)
    },
    table.header([Argument]),

    [Nil],
  )
}

#let return_table_empty() = {
  table(
    columns: 1,
    align: horizon,
    inset: 10pt,
    fill: (_, y) => if y == 0 {
      gray.lighten(70%)
    },
    table.header([Returns]),

    [Nil],
  )
}

#let arguments_return_table_empty() = {
  table(
    columns: 2,
    align: horizon,
    inset: 10pt,
    fill: (_, y) => if y == 0 {
      gray.lighten(70%)
    },
    table.header([Argument], [Returns]),
    [Nil], [Nil],
  )
}
// ------------------------------------------------------------------------------

// Table of Contents
#show outline.entry.where(level: 1): it => {
  strong(it)
}
#outline(depth: 2, indent: auto)
#pagebreak()
// ------------------------------------------------------------------------------

// Heading setup after toc such that it does not affect table of contents
#show heading.where(level: 1): it => block(width: 100%)[
  #v(80pt)
  #it
]

#show heading.where(level: 2): it => block(width: 100%)[
  #v(20pt)
  #it
]

//#show heading.where(level: 3): it => block(width: 100%)[
//  #v(5pt)
//  #it
//]
// ------------------------------------------------------------------------------

// Start
= Introduction

ILL is a module that aims to make working with subtitle objects efficient. It does most of the heavy lifting so that we can do more with fewer lines of code in our script. It provides various functions that allow us to work with lines, tags, drawings, text and comments. This makes it unnecessary to reinvent the wheel and write your own functions to do most of the common task while still allowing you to do complex tasks more easily.


= Skeleton of Aegisub Scripts

#code(```lua
export script_name = "name of the script"
export script_description = "description of your script"
export script_version = "0.0.1"
export script_author = "you"
export script_namespace = "namespace of your script"

DependencyControl = require "l0.DependencyControl"
depctrl = DependencyControl{
    {
        {
            "ILL.ILL"
            version: "0.0.1"
            url: "https://github.com/TypesettingTools/ILL-Aegisub-Scripts"
            feed: "https://raw.githubusercontent.com/TypesettingTools/ILL-Aegisub-Scripts/main/DependencyControl.json"
        }
    }
}
ILL = depctrl\requireModules!
{:Aegi, :Ass} = ILL

functionName = (sub, sel, act) ->
    -- stuff goes here

depctrl\registerMacro functionName
```)

This is the framework that all your scripts will have. Here we import ILL as well as classes that ILL offers that we need in this script. Here, we only import `Aegi` and `Ass` class but ILL offers much more and user should import them as they are needed. Finally, we define a function called `functionName`. This function name is what we register in Aegisub in the last line, and it gets executed as soon as we run the script. Everything we do in the guide below will go inside the function where `--stuff goes here` is written.

= Aegi

Class `Aegi` deals with various Aegisub api and provides convenience function wrappers around them.

== ffm

`ffm` uses the loaded framerate data to convert absolute time in milliseconds to a frame number.

=== Arguments
#argument_table(([ms], [Time in milliseconds], [Integer], [-]))

=== Returns
If video is not open, it returns nil.
#return_table(([frame or nil], [Frame corresponding to time], [integer or nil]))

=== Usage
#code(```lua
frame = Aegi.ffm 1000
frame = Aegi.ffm line.start_time
```)

== mff

`mff` uses loaded framerate data to convert a frame number of the video into an absolute time in milliseconds.

=== Arguments
#argument_table(([frame], [Frame number of video], [integer], [-]))

=== Returns
If video is not open, it returns nil.
#return_table(([millisecond or nil], [Time in milliseconds], [integer or nil]))

=== Usage
#code(```lua
ms = Aegi.mff 100
line.start_time = Aegi.mff 500
```)

== progressTitle

A progress dialog box is always shown when an Aegisub script is run. Aegisub allows user to modify what is shown in it. `progressTitle` sets the title for the progress window. Title is the large text displayed above the progress bar. This text should usually not change while the script is running. By default, title is set to the name of the macro running.

#align(center, image("images/progress_window.png", width: 60%))
=== Arguments
#argument_table(([title], [Title to set int the progress window], [String], [-]))

=== Returns
#return_table_empty()

=== Usage
#code(```lua
Aegi.progressTitle "Title of the progress window."
```)

== progressTask

`progressTask` sets the text for the progress window. Task is the small text below the progress bar showing what the script is currently doing. It is updated by the user as the task of the script changes.

=== Arguments
#argument_table(([task], [Task that the script is currently executing], [String], [""]))

=== Returns
#return_table_empty()

=== Usage
#code(```lua
Aegi.progressTask "Plotting World Domination."
```)

== progressSet
`progressSet` generates a progress bar in the progress window ranging from 0% to 100%.

=== Arguments
#argument_table(([i], [Current index], [Integer], [-], [n], [Total index], [Integer], [-]))

=== Returns
#return_table_empty()

=== Usage
#code(```lua
for i = 1, 20
    Aegi.progressSet i, 20
```)

== progressReset

`progressReset` resets all the progress by setting the progress bar to 0% and progress task to empty string.

=== Arguments and Returns
#arguments_return_table_empty()

=== Usage
#code(```lua
Aegi.progressReset!
```)

== progressCancelled

`progressCancelled` checks if the user has cancelled the execution of script. In such a case, it stops any further execution of the script. It should be used inside loops or callback functions such that the user does not have wait until it is completed to stop the execution of the script.

=== Arguments and Returns
#arguments_return_table_empty()

=== Usage
#code(```lua
Aegi.progressCancelled!
```)

== progressLine <progressLine>

`progressLine` is a combination of a couple of functions that we have seen above so that we can execute all of them at once. It is recommended to use this unless for some reason you need to execute them separately.

This sets the progress bar, sets the progress task and checks for user cancellation. This is ideal to be used inside a loop or callback function.

=== Arguments
#argument_table((
  [Line],
  [Line table as given by `Ass` class],
  [Table],
  [-],
  [i],
  [Current index],
  [Integer],
  [-],
  [n],
  [Total index],
  [Integer],
  [-],
))

More info about getting line table from `Ass` class is discussed later.

=== Returns

#return_table_empty()

=== Usage

#code(```lua
ass = Ass sub, sel
ass\iterLines (l, i, n) ->
    Aegi.progressLine l, i, n
```)

== videoIsOpen

`videoIsOpen` is used to find if video is currently open in Aegisub or not.

=== Arguments
#argument_table_empty()

=== Returns
#return_table(([videoState], [State of video], [True if open and false if closed]))

=== Usage
#code(```lua
if Aegi.videoIsOpen!
    -- video is open
else
    -- video is not open
```)

== getFramerate

`getFramerate` returns the framerate of the video that is currently open. If the video is not open, it returns the default value of 24000 / 1001.

=== Arguments
#argument_table_empty()

=== Returns
#return_table(([framerate], [Framerate of the video], [Float]))

=== Usage
#code(```lua
framerate = Aegi.getFramerate!
```)

= Logger

Class `Logger` allows you to log messages to the progress window. If messages are logged by a script, the progress window stays open after the script has finished running until the user clicks the `Close` button.

Logger has two components: Log level and messages. Log level indicates the severity level of the message while messages are the string that you want to log.

By default, Aegisub's log level is set to 3 which means that the message above 3 won't be seen by end user unless they set the log level higher themselves.

== Fatal

These message indicate something really bad happened and the script cannot continue. The log level of these messages is 0. Level 0 messages are always shown regardless of trace level settings in Aegisub. The execution of the script will end after this message is logged.


== Error
An error indicates the user should expect something to have gone wrong even though you tried to recover. A fatal error might happen later. The log level of error messages is 1.

== Warn
A warning indicates something is wrong and the user ought to know because it might mean something needs to be fixed. The log level of warning messages is 2.

== Hint

A hint indicates something that the user should know that is not necessarily a cause for alarm. The log level of hint messages is 3.

== Debug

A debug message includes information meant to help fix errors in the script, such as dumps of variable contents. Since the default trace level of Aegisub is 3, debug messages, which has the log level of 4, won't be seen by average user of the script unless they manually changed it. This is useful for script writers during the debugging of their scripts.

== Trace

A track message includes extremely verbose information about what the script is doing, such as a message for each single step done with lots of variable dumps.
The log level of trace message is 5.

== Log

This is simply a wrapper around hint message who don't want to use `hint` and want to use `log` which seems synonymous to simply logging messages.

#strong([Arguments])

#argument_table((
  [messages],
  [Message you want to show],
  [string / number / boolean / table],
  [-],
  [...],
  [Parameters to the format string],
  [lua string.format parameters],
  [-],
))

#strong([Returns])
#return_table_empty()

=== Usage
#code(```lua
Logger.fatal "This is a fatal message."     -- log level 0
Logger.error "This is an error message."    -- log level 1
Logger.warn "This is a warning message."    -- log level 2
Logger.hint "This is a hint message."       -- log level 3
Logger.debug "This is a debug message."     -- log level 4
Logger.trace "This is a trace message."     -- log level 5

Logger.log "This is a simple message."      -- log level 3
```)
You can also use Lua's string.format method.

#code(```lua
Logger.fatal "There are %d %s messages.", 5, "fatal"
```)
This will yield the message: `There are 5 fatal messages.`

== Assert <Assert>
`assert` will only show a message if a condition is false. After showing the message, further execution of script is terminated.

=== Argument
#argument_table((
  [condition],
  [Condition to check],
  [lua statement or boolean],
  [-],
  [message],
  [Message you want to show if condition is false],
  [string / number / boolean / table],
  [-],
  [...],
  [Parameters to the format string],
  [lua string.format parameters],
  [-],
))

=== Returns
#return_table_empty()

=== Usage
#code(```lua
Logger.assert 1 > 2, "Unfortunately, 1 was not greater than 2."
```)

== windowError <windowError>

Instead of using progress window, if the user wants to use Aegisub dialog to show messages, this can be used. Currently this only supports text messages. The execution of the script will be terminated after the message is shown.

=== Arguments
#argument_table((
  [message],
  [Message you want to show],
  [string / number / boolean / table],
  [-],
  [...],
  [Parameters to the format string],
  [lua string.format parameters],
  [-],
))

=== Returns
#return_table_empty()

=== Usage
#code(```lua
Logger.windowError "This is a message\nThis is another line of the message"
```)

The above command will yield:

#align(center, image("images/window_error.png", width: 50%))

== windowAssertError

`windowAssertError` is the same as the @windowError `windowError` and @Assert `assert` combined.

=== Arguments and Returns
Same as @Assert

=== Usage
#code(```lua
Logger.windowAssertError line.start_time < line.end_time, "This is a message\nThis is another line of the message"
```)

== lineWarn <lineWarn>

`lineWarn` is used for showing warning for a particular line.

=== Arguments
#argument_table((
  [line],
  [line collected by `Ass` class],
  [table],
  [-],
  [message],
  [Message you want to show],
  [string],
  ["not specified"],
))

=== Returns
#return_table_empty()

=== Usage

#code(```lua
ass = Ass sub, sel
ass\iterLines (l, i, n) ->
    Logger.lineWarn l, "Clip not found in line."
```)

The code above yields:
#align(center, image("images/line_warn.png", width: 50%))

== lineError

`lineError` is used for showing critical warning for a particular line. The execution of the script is terminated after showing this message.

=== Arguments and returns
Same as @lineWarn

=== Usage

#code(```lua
ass = Ass sub, sel
ass\iterLines (l, i, n) ->
    Logger.lineError l, "Clip not found in line."
```)

The code above yields:
#align(center, image("images/line_error.png", width: 50%))

= Ass

One of the first things we do when we write a script is we initiate the `Ass` instance. It's job is to collect the basic information of the subtitle files, lines of the files and provide various methods to act on them.

#code(```lua
main = (sub, sel, act) ->
    ass = Ass sub, sel, act
```)

#strong([Arguments])
#argument_table((
  [sub],
  [Subtitle object given by Aegisub],
  [userdata],
  [-],
  [sel],
  [(Optional) Selected lines],
  [table[integer]],
  [-],
  [act],
  [(Optional) Active line],
  [integer],
  [-],
  [callback],
  [(Optional) condition for line collection],
  [function],
  [```lua (l) -> not l.comment```],
))

//It returns a table with all the information and is stored in the variable `ass`. The general structure of the table will look like this:
//
//#code(```lua
//{
//    -- Metadata of the subtitle file
//    meta: {
//        title: "Default Aegisub file"
//        res_x: 1920
//        res_y: 1080
//        wrapstyle: "0"
//        playresx: "1920"
//        playresy: "1080"
//        scripttype: "v4.00+"
//        ycbcr matrix: "None"
//        video_x_correct_factor: 1
//        scaledborderandshadow: "yes"
//    }
//    -- List of styles along with their styleref
//    styles: {
//        Default: {
//            name: "Default"
//            fontname: "Arial"
//            ...
//        }
//    }
//    -- Sub instance as given by Aegisub
//    sub:
//    -- Table of selected lines' index
//    sel: { }
//    -- Index of active line
//    activeLine:
//    -- Collected Lines
//    lines:{
//
//        }
//}
//```)


== Line Collection
As we initialize the `Ass` class, we are collecting lines to work on at the same time. By default, the condition ```lua (line) -> line.comment``` suggests that only uncommented lines are collected but that can be changed.

The collected line table will have lines with all the #link("https://aegisub.org/docs/latest/automation/lua/modules/karaskel.lua/#dialogue-line-table")[fields of a normal line table] but it adds other fields.


#table(
  columns: 3,
  align: horizon,
  inset: 10pt,
  fill: (_, y) => if y == 0 {
    gray.lighten(70%)
  },
  table.header([Argument], [Description], [Type]),
  [duration], [duration of line in milliseconds], [integer],
  [startFrame], [start frame of a line], [integer],
  [endFrame], [end frame of a line], [integer],
  [frameCount], [total number of frames], [integer],
  [styleRef],
  [#link("https://aegisub.org/docs/latest/automation/lua/modules/karaskel.lua/#style-table")[style table of current line]],
  [table],

  [absoluteIndex], [actual index of line in subtitle file], [integer],
  [naturalIndex], [index of line as seen in Aegisub], [integer],
)

=== Collect all dialogue lines
If you only send sub as an argument, all uncommented lines will be collected.

#note([
  All lines does not mean all lines of the subtitle. It means all the dialogue lines as seen in Aegisub.
])

#code(```lua
main = (sub, sel, act) ->
    ass = Ass sub
```)

=== Collect all selected lines

If you send both `sub` and `sel` as arguments, only the uncommented dialogue lines among the selected lines will be collected.

#code(```lua
main = (sub, sel, act) ->
    ass = Ass sub, sel
```)

=== Choosing conditions for collection
There may be cases where you want to only collect certain types of lines. In that case, you can override the default condition for line collection.

If you don't like that it skips over commented lines and want it to be included, collect lines as shown below. It will select all selected lines without checking anything.

#code(```lua
ass = Ass sub, sel, act, -> return true
```)

In fact, you can give any condition here and if that condition is fulfilled, only those lines will be collected i.e. if the callback function returns `true`, the line will be collected and vice versa. For example, if you want to only collect commented lines.

#code(```lua
ass = Ass sub, sel, act, -> return line.comment
```)

If you want to only collect lines whose layer is 1:

#code(```lua
ass = Ass sub, sel, act, ->
    return line.layer == 1
```)

If yo want to only collect lines whose text contain certain substring:

#code(```lua
ass = Ass sub, sel, act, ->
    return line.text\match "text"
```)

== Loop through collected lines

Now that we have collected lines, we might want to iterate through it and work on individual lines.

#code(```lua
main = (sub, sel, act) ->
    ass = Ass sub, sel
    return if #ass.lines == 0          -- Return early if no lines were collected.
    ass\iterLines (l, i, n) ->
        -- do things to individual line here.
```)

=== Arguments
One of the argument of `ass\iterLines` is a callback function which means it will offer you a few arguments that you can use.

#argument_table((
  [l],
  [line table],
  [table],
  [-],
  [i],
  [current iteration of line],
  [integer],
  [-],
  [n],
  [total number of lines in collection],
  [integer],
  [-],
))

The argument `l` is the line table which contains all the information about current line. However, the other arguments `i` and `n` are purely for progress reporting. An example was shown in @progressLine.

=== Returns
While iterating through the lines, if we want to stop the iteration, we can return false.

#return_table(([stop iteration], [if iteration should be stopped], [boolean]))

For example:

#code(```lua
main = (sub, sel, act) ->
    ass = Ass sub, sel
    return if #ass.lines == 0
    ass\iterLines (l, i, n) ->
        if condition
            return false
            -- As soon as this callback function returns false, the iteration will stop.
```)

== Remove Lines

If you want to remove lines from the collection, you can mark them for removal during the iteration.

#warning([This only marks the line for removal. Line has not been actually removed from the subtitle yet. Look @assCommit for more.])

=== Arguments
#argument_table((
  [line],
  [line collected by `Ass` class ],
  [table],
  [-],
))

=== Returns
#return_table_empty()

=== Usage
#code(```lua
main = (sub, sel, act) ->
    ass = Ass sub, sel
    return if #ass.lines == 0
    ass\iterLines (l, i, n) ->
        if i % 3 == 0
            ass\removeLine l
```)


== Insert Line

You want to insert lines to the subtitle at some point. If you are iterating through the collection, make a copy of the line before inserting it or you can create a line from scratch to insert at any time. Look @createLines for how to create lines from scratch.

#warning([This only marks the line for insertion. Line has not been actually inserted to the subtitle yet. Look @assCommit for more.])

=== Arguments
#argument_table((
  [line],
  [line collected by `Ass` class ],
  [table],
  [-],
  [index],
  [(Optional) index of the collection at which to insert the line],
  [integer],
  [\#ass.lines],
))

In case the user gives the index too low or high, the index is clamped to be 1 and total number of lines so that it is always within the collection. If index is not provided, it will add the line at the end of the collection.

=== Returns
#return_table_empty()

=== Usage
#code(```lua
main = (sub, sel, act) ->
    ass = Ass sub, sel
    return if #ass.lines == 0
    ass\iterLines (l, i, n) ->
        line = Table.deepcopy l
        -- Make some changes to the copy
        line.layer += 1
        line.text = "This is a copy of line #{line.naturalIndex}"
        if i % 3 == 0
            ass\insertLine line  -- inserts line at the end of collection
        elseif i % 5  == 0
            ass\insertLine line, i  -- inserts line right after current line
```)

== Commit changes to the subtitle <assCommit>

After we make various changes to the line collection, this is where we actually commit the changes to the subtitle file. This removes all the lines that were marked for removal, inserts lines at the index the user asked them to insert and apply the changes the user makes on the line.

=== Arguments
#argument_table(([updateRefs], [update references of the line after comitting], [boolean], [false]))

#note([
  When the user commits and makes changes to the subtitle file, the line collection will become outdated. The indices may point to wrong lines. If the user changes times of the line, the fields related to frames also become wrong. If the user does not want to work with the line collection again (i.e. the script no longer has to iterate through lines again), there is no need to update references. However, if the user wants to iterate through lines again, we need to fix the references so that we're sure we're working with proper lines.
])

=== Returns
#return_table_empty()

=== Usage
#code(```lua
main = (sub, sel, act) ->
    ass = Ass sub, sel
    return if #ass.lines == 0
    ass\iterLines (l, i, n) ->
        if i % 3 == 0
            line = Table.deepcopy l
            line.text = "This is a copy of line #{line.naturalIndex}"
            ass\insertLine line, i
        elseif i % 5  == 0
            ass\removeLine l
    ass\commit!
```)

#code(```lua
    ass\commit true -- if you want to update the line collection
```)



== Create Lines <createLines>

== Add Style

== Update Metadata

== Parse Line

== Get selection

This gets the table of selected lines. This is most useful to be returned by the main function of the script and whatever indices are present in the table, those lines will be selected after the script is run.

=== Arguments
#argument_table_empty()

=== Returns
#return_table(([sel], [indices of selected lines], [table]))

=== Usage

#code(```lua
main = (sub, sel, act) ->
    ass = Ass sub, sel
    return if #ass.lines == 0
    ass\iterLines (l, i, n) ->
        -- make changes here
    ass\commit!
    return Ass\getSelection!
```)

As the user removes line or inserts line, the selection table gets updated. Therefore, `getSelection` returns the proper indices after working with lines.

= Table
`Table` consists of various actions user can perform on the Lua tables. Lua does not differentiate between a dictionary and a list. Therefore, user must first verify if the function below is applicable to the table before applying. The function will be tagged with `List` for arrays, `Table` for dictionary and will be tagged with both if the function can be used for either.

== isEmpty

Tags: List, Table

`isEmpty` is used to find if the table is empty.

=== Arguments
#argument_table(([table], [table to check if it is empty], [table], [-]))

=== Returns
#return_table(([table empty state], [true if table is empty, false otherwise], [boolean]))

=== Usage
#code(```lua
if Table.isEmpty {1, 2, 3}
    -- table is empty
else
    -- table is not empty
```)

== isList

Tags: List, Table

`isList` is used to find if the table is a list or a dictionary.

=== Arguments
#argument_table(([table], [table to check if it is list or dictionary], [table], [-]))

=== Returns
#return_table(([table list state], [true if table is list, false otherwise], [boolean]))

=== Usage
#code(```lua
if Table.isList {1, 2, 3}
    -- table is list
else
    -- table is dictionary
```)

== shallowcopy <shallowcopy>

Tags: List, Table

`shallowcopy` as the name suggests makes a shallow copy of the table

=== Arguments
#argument_table(([table], [table to check if it is list or dictionary], [table], [-]))

=== Returns
#return_table(([shallow copy], [shallow copy of the table], [boolean]))

=== Usage
#code(```lua
copy = Table.shallowcopy {1, 2, 3}
```)

== deepcopy

Everything about `deepcopy` is same as @shallowcopy: `shallowcopy` above except it returns a deep copy of the table.

== map

Tags: List, Table

`map` is used to apply a user defined function to each element of the table.

=== Arguments
#argument_table((
  [table],
  [table to map elements of],
  [table],
  [-],
  [callback function],
  [function to apply to each element],
  [function],
  [-],
))

==== Arguments of callback function
#argument_table((
  [value],
  [value that you are modifiying],
  [any except nil/NaN],
  [-],
  [key],
  [key in case of table, index in case of list],
  [any except nil/NaN],
  [-],
))

==== Returns of callback function
#return_table(([value], [modified value], [any except nil/NaN]))

=== Returns
#return_table(([modified table], [table where each element is returned by callback function], [table]))

=== Usage

#code(```lua
tbl = {1, 2, 5}
tbl = Table.map tbl, (value) -> value + 1

-- Output
-- tbl = {2, 3, 6}
```)

#code(```lua
tbl = {1, 2, 5, "apple"}
tbl = Table.map tbl, (value) ->
    if type(value) == "string"
        value = value\gsub "p", "b"
    else
        value *= 2
    return value

-- Output
-- tbl = {2, 4, 10, "abble"}
```)

#code(```lua
tbl = {
    "key1": 1
    "key2": 2
    "key3": 5
}
tbl = Table.map tbl, (v, k) ->
    if k == "key2"
        return v
    else
        return v + 1
-- Output
-- tbl = {
--     "key1": 2
--     "key2": 2
--     "key3": 6
-- }
```)

== filter

Tags: List, Table

`filter` is used to only keep elements which satisfy a condition.

=== Arguments
#argument_table((
  [table],
  [table to filter elements of],
  [table],
  [-],
  [callback function],
  [function that defines the condition],
  [function],
  [-],
))

==== Arguments of callback function
#argument_table((
  [value],
  [value that you are modifiying],
  [any except nil/NaN],
  [-],
  [key],
  [key in case of table, index in case of list],
  [any except nil/NaN],
  [-],
))
==== Returns of callback function
#return_table(([state], [condition has passed or not], [boolean]))

=== Returns
#return_table(([modified table], [table where each element is returned by callback function], [table]))

=== Usage

#code(```lua
tbl = { 1, 2, 3, 4, 5, 6, 7, 8, 9}
tbl = Table.filter tbl, (v) -> v % 3 == 0

-- Output
-- tbl = {3, 6, 9}
```)

#code(```lua
tbl = {
    "key1": "foo"
    "key2": "bar"
    "key3": 5
    "key4": 10
}
tbl = Table.filter tbl, (v, k) ->
    if k == "key4"
        return true
    else
        return type(v) == "string"

-- Output
-- tbl = {
--     "key1": "foo"
--     "key2": "bar"
--     "key4": 10
-- }
```)

== size

Tags: List, Table

`size` is used to find the total number of elements in a table. While you can use ```lua #tbl``` to find the number of elements in a list, you cannot do the same for a dictionary.

For example, in a table ```lua tbl = {1, "foo": 1, 2, "bar": 2}```, ```lua #tbl``` will return 2 as it will not count key value pair in the table.

=== Arguments
#argument_table(([table], [table whose size must be calculated], [table], [-]))

=== Returns
#return_table(([size], [number of elements of table], [integer]))

=== Usage

#code(```lua
tbl = { 1, "foo": 1, 2, "bar": 2}
count = Table.size tbl

-- Output
-- count = 4
```)

== contains

Tags: List, Table

`contains` is used to find if a table contains a certain value. In a list, it checks if an element exists in array. In a key-value pair, it checks if any key has that certain value.

=== Arguments
#argument_table((
  [table],
  [table to check the value in],
  [table],
  [-],
  [value],
  [value to check],
  [number / boolean / string],
  [-],
))

=== Returns
#return_table(([state], [true if value exists, false otherwise], [boolean]))

=== Usage
#code(```lua
tbl = { 1, 2, 3, 4, 5, 6, 7, 8 ,9}
Table.contains tbl 10  -- returns false
Table.contains tbl 7   -- returns true
```)
#code(```lua
tbl = { 1, 2, "foo": "bar", 3, 4}
Table.contains tbl, "bar" -- returns true
```)

== keys

Tags: Table, List

`keys` is used to get a list of keys of a table. In a list, it will return an array of indices but in a key-value pair, it will return an array of keys only.

=== Arguments
#argument_table(([table], [table to find keys of], [table], [-]))

=== Returns
#return_table(([list], [list of keys], [table]))

=== Usage
#code(```lua
tbl = {"foo": 1, "bar": 2}
keys = Table.keys tbl

-- Output
-- keys = {"foo", "bar"}
```)

#code(```lua
tbl = {"foo", "bar"}
keys = Table.keys tbl

-- Output
-- keys = {1, 2}
```)

== count

Tags: Table, List

`count` is used to count how many elements satisfy a condition.

=== Arguments
#argument_table((
  [list],
  [list to count element of],
  [table],
  [-],
  [callback function],
  [function that defines the condition],
  [function],
  [-],
))

==== Arguments of callback function
#argument_table((
  [value],
  [value that you are modifiying],
  [any except nil/NaN],
  [-],
  [key],
  [key in case of table, index in case of list],
  [any except nil/NaN],
  [-],
))
==== Returns of callback function
#return_table(([count], [number of elements that pass the condition], [boolean]))

=== Returns
#return_table(([occurence], [number of occurence of value], [integer]))

=== Usage
#code(```lua

tb = {1, 2, 3, 1, 4, 1}
result = Table.count tb, (v) -> v == 1

-- Output
-- result = 3

result = Table.count tb, (v) -> v > 2

-- Output
-- result = 2
```)


== pop

Tags: #text(red, [List only])

`pop` is used to remove an element from the list.

=== Arguments
#argument_table((
  [list],
  [list to remove element of],
  [table],
  [-],
  [index],
  [(Optional) index of element to remove],
  [integer],
  [last element of list],
))

If index is not provided, the last element of the array is removed.

=== Returns
#return_table(([table], [table with elements popped], [table]))

=== Usage
#code(```lua
tbl = Table.pop {1, 2, 3, 4, 5}

-- Output
-- {1, 2, 3, 4}
```)

#code(```lua
tbl = Table.pop {1, 2, 3, 4, 5}, 3  -- remove third element

-- Output
-- {1, 2, 4, 5}
```)

== reverse

Tags: #text(red, [List only])

`reverse` is used to reverse elements from the list.

=== Arguments
#argument_table((
  [list],
  [list to reverse element of],
  [table],
  [-],
))

=== Returns
#return_table(([table], [table with elements reversed], [table]))

=== Usage
#code(```lua
tbl = Table.reverse {1, 2, "foo", 3, 4, "bar", 5}

-- Output
-- {5, "bar", 4, 3, "foo", 2, 1}
```)

== slice

Tags: #text(red, [List only])

`slice` is used to extract a section of a list based on the specified start, end and step parameters.

=== Arguments
#argument_table((
  [list],
  [list to extract section of],
  [table],
  [-],
  [start index],
  [(Optional) starting index of the slice],
  [integer],
  [1],
  [end index],
  [(Optional) ending index of the slice],
  [integer],
  [last item of the list],
  [step],
  [(Optional) step size for iteration],
  [integer],
  [1],
))

=== Returns
#return_table(([table], [extracted section of list], [table]))

=== Usage
#code(```lua
tb = {10, 20, 30, 40, 50}

result = Table.slice tb, 2, 4  -- extract from index 2 to 4

-- Output
-- result = {20, 30, 40}

result = Table.slice tb, 1, 5, 2  -- extract from index 1 to 5 with step 2

-- Output
-- result = {10, 30, 50}

result = Table.slice tb, 4, 2, -1  -- extract from index 4 to 2 with step -1 i.e. in reverse

-- Output
-- {40, 30, 20}
```)

== extend

Tags: #text(red, [List only])

`extend` is used to extend a list by appending elements from one or more lists.

=== Arguments
#argument_table((
  [list],
  [list to extend],
  [table],
  [-],
  [...],
  [any number of lists separated by comma],
  [table],
  [-],
))

=== Returns
#return_table(([table], [combined lists], [table]))

=== Usage
#code(```lua
list1 = {1, 2, 3}
list2 = {4, 5}
list3 = {6, 7, 8}
result = Table.extend list1, list2, list3

-- Output
-- result = {1, 2, 3, 4, 5, 6, 7, 8}
```)

== uniq

Tags: #text(red, [List only])

`uniq` is used to remove duplicate elements from a list.

=== Arguments
#argument_table((
  [list],
  [list to count element of],
  [table],
  [-],
))

=== Returns
#return_table(([occurence], [number of occurence of value], [integer]))

=== Usage
#code(```lua

list = {1, 2, 3, 1, 4, 2, 5}
result = Table.uniq list

-- Output
-- result = {1, 2, 3, 4, 5}
```)

== diff

Tags: #text(red, [List only])

`diff` is used to remove elements from a list that are present in any of the additional lists.

=== Arguments
#argument_table((
  [list],
  [base list],
  [table],
  [-],
  [...],
  [any number of lists separated by comma],
  [table],
  [-],
))

=== Returns
#return_table(([list], [list with elements only in first list], [table]))

=== Usage
#code(```lua
list = {1, 2, 3, 4, 5, 6}
list1 = {3, 4}
list2 = {1, 2}

result = Table.diff list, list1, list2

-- Output
-- result = {5, 6}
```)

== intersect

Tags: #text(red, [List only])

`intersect` is used to find elements that exists in all lists.

=== Arguments
#argument_table((
  [...],
  [any number of lists separated by comma],
  [table],
  [-],
))

=== Returns
#return_table(([list], [list with elements found in all input lists], [table]))

=== Usage
#code(```lua
list = {1, 2, 3, 4, 5, 6}
list1 = {1, 3, 5}
list2 = {1, 5, 10}

result = Table.intersect list, list1, list2

-- Output
-- result = {1, 5}
```)

== removeIndices

Tags: #text(red, [List only])

`removeIndices` removes the elements at the specified indices.

=== Arguments
#argument_table((
  [list],
  [list to remove indices of],
  [table],
  [-],
  [indices],
  [indices to remove],
  [table],
  [-],
))

=== Returns
#return_table(([list], [list with elements of the indices removed], [table]))

=== Usage
#code(```lua
tb = {10, 20, 30, 40, 50}
result = Table.removeIndices tb, {2, 4}

-- Output
-- result = {10, 30, 50}
```)

== removeValues

Tags: #text(red, [List only])

`removeValues` is used to remove elements with a specific value or list of values from a list.

=== Arguments
#argument_table((
  [list],
  [list to remove values from],
  [table],
  [-],
  [value(s)],
  [value or list of values],
  [number / string / boolean],
  [-],
))

=== Returns
#return_table(([list], [list with elements with value(s) removed], [table]))

=== Usage
#code(```lua
tb = {"foo", "bar", "baz", "foo"}
result = Table.removeValues tb, "foo"

-- Output
-- result = {"bar", "baz"}
```)

#code(```lua
tb = {"foo", "bar", "baz", "foo"}
result = Table.removeValues tb, {"bar", "baz"}

-- Output
-- result = {"foo", "foo"}
```)

== makeSet

Tags: #text(red, [List only])

`makeSet` is used make a set of a list i.e. a key-value table where key is the element of the list and value is `true`. The sets have no duplicates. This is mostly useful for fast lookups of unique elements present in a list.

=== Arguments
#argument_table((
  [list],
  [list to make set of],
  [table],
  [-],
))

=== Returns
#return_table(([table], [table that is set of input list], [table]))

=== Usage
#code(```lua
tb = {"foo", "bar", "baz", "foo"}
result = Table.removeValues tb, "foo"

-- Output
-- result = {
--   foo: true
--   bar: true
--   baz: true
-- }
```)

== prepend

Tags: #text(red, [List only])

`prepend` is used to add a single or list of elements to the beginning of the list.

=== Arguments
#argument_table((
  [list],
  [list to prepend elements to],
  [table],
  [-],
  [value(s)],
  [value or list of values],
  [number / string / boolean],
  [-],
))

=== Returns
#return_table(([list], [list with elements prepended], [list]))
=== Usage
#code(```lua
tb = {3, 4, 5}
result = Table.prepend tb, {1, 2}

-- Output
-- result = {1, 2, 3, 4, 5}
```)

#code(```lua
tb = {3, 4, 5}
result = Table.prepend tb, "foo"

-- Output
-- result = {"foo", 3, 4, 5}
```)

== splice

Tags: #text(red, [List only])

`splice` is used to modify a list by adding or replacing elements starting at a specific position while also removing a specified number of elements. This can replace, insert, remove element at any index at once.

=== Arguments
#argument_table((
  [list],
  [list to modify],
  [table],
  [-],
  [start],
  [index at which to start adding or removing elements],
  [integer],
  [-],
  [delete],
  [number of elements to remove starting at start index],
  [integer],
  [-],
  [...],
  [any number of elements to be inserted at start index],
  [any],
  [-],
))

=== Returns
#return_table(([removes], [list of removed elements], [list]))

The original list is modified in place so it is not returned.

=== Usage

==== Replace Elements

#code(```lua
tb = {1, 2, 3, 4, 5}
result = Table.splice tb, 2, 2, 9, 10

-- Output
-- tb = {1, 9, 10, 4, 5}
-- result = {1, 2, 3, 4, 5}
```)

+ Starts at index 2
+ Removes 2 elements ```lua {2, 3}```
+ Inserts ```lua {9, 10}``` at index 2

==== Insert Elements Only
#code(```lua
tb = {1, 2, 3}
result = Table.splice tb, 2, 0, 8, 9

-- Output
-- tb = {1, 8, 9, 2, 3}
-- result = {}
```)

+ Starts at index 2
+ Removes 0 elements
+ Inserts ```lua {8, 9}``` at index 2

==== Remove Elements Only
#code(```lua
tb = {1, 2, 3, 4}
result = Table.splice tb, 2, 3

-- Output
-- tb = {1}
-- result = {2, 3, 4}
```)

+ Starts at index 2
+ Removes 3 elements ```lua {2, 3, 4}```
+ Inserts no new elements

== invert

Tags: #text(red, [Table only])

`invert` is used to create a new table with keys and values swapped.

=== Arguments
#argument_table((
  [table],
  [table to invert],
  [table],
  [-],
))

=== Returns
#return_table(([table], [table with key and value inverted], [table]))

=== Usage
#code(```lua
tb = { "foo": "bar", "baz": 1 }
result = Table.invert tb

-- Output
--result = {
--	1: "baz"
--	"bar": "foo"
--}
```)

== merge

Tags: #text(red, [Table only])

`merge` is used to combine key-value tables. The later tables overwrite keys from earlier ones.

=== Arguments
#argument_table((
  [...],
  [any number of tables to merge],
  [table],
  [-],
))

=== Returns
#return_table(([table], [merged table], [table]))

=== Usage
#code(```lua
table1 = { a: 1, b: 2 }
table2 = { b: 3, c: 4 }
table3 = { d: 5 }
result = Table.merge table1, table2, table3

-- Output
--result = {
--	a: 1
--	c: 4
--	b: 3
--	d: 5
--}
```)

== equal

Tags: List, Table

`equal` is used to find out if any two tables are equal or not.

=== Arguments
#argument_table((
  [first table],
  [first table to compare],
  [table],
  [-],
  [second table],
  [second table to compare],
  [table],
))

=== Returns
#return_table(([state], [true if tables are equal, false otherwise], [boolean]))

=== Usage
#code(```lua
tbl1 = { a: 1, b: { x: 10, y: 20 }, c: 3 }
tbl2 = { a: 1, b: { x: 10, y: 20 }, c: 3 }
tbl3 = { a: 1, b: { x: 10, y: 30 }, c: 3 }
Table.equal tbl1, tbl2  -- returns true
Table.equal tbl1, tbl3  -- returns false
```)

== view

Tags: List, Table

`view` is used to convert table to string. The produced string is a valid moonscript table. This is used by `Logger` module and is mostly useful for debugging purposes.

=== Arguments

#argument_table((
  [table],
  [table to view],
  [table],
  [-],
  [name],
  [(Optional) name of the table],
  [string],
  [table_unnamed],
  [indent],
  [(Optional) indent each line with a string],
  [string],
  [""],
))

=== Returns
#return_table(([table view], [string representation of table], [string]))

=== Usage

#code(```lua

tb = {1, 2, 3, 4}
result = Table.view tb

-- Output
-- table_unnamed = {
-- 	1: 1
-- 	2: 2
-- 	3: 3
-- 	4: 4
-- }
```)

#code(```lua
tb = {"foo": 1, 2, "bar": 3, "baz": 4, 5}
result = Table.view tb, "name"

-- Output
--name = {
--	1: 2
--	2: 5
--	"bar": 3
--	"foo": 1
--	"baz": 4
--}
```)
