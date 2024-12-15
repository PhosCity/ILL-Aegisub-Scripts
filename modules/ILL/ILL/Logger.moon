Table = require "ILL.ILL.Table"

logger = (level, message, ...) ->

    if type(message) == "table"
        aegisub.log level, Table.view message
    else
        aegisub.log level, tostring(message) .. "\n", ...

    aegisub.cancel! if level == 0


-- https://aegisub.org/docs/latest/automation/lua/progress_reporting/#aegisubdebugout
return {

    fatal: (message, ...) -> logger 0, message, ...

    error: (message, ...) -> logger 1, message, ...

    warn: (message, ...) -> logger 2, message, ...

    hint: (message, ...) -> logger 3, message, ...

    debug: (message, ...) -> logger 4, message, ...

    trace: (message, ...) -> logger 5, message, ...

    log: (message, ...) -> logger 2, message, ...

    assert: (condition, message, ...) ->
        unless condition
            logger 0, message, ...

    windowError: ( message, ... ) ->
        if ...
            message = message\format ...
        aegisub.dialog.display { { class: "label", label: message } }, { "&Close" }, { cancel: "&Close" }
        aegisub.cancel!

    windowAssertError: (condition, message, ...) ->
        return if condition
        if ...
            message = message\format ...
        aegisub.dialog.display { { class: "label", label: message } }, { "&Close" }, { cancel: "&Close" }
        aegisub.cancel!

    lineWarn: (line, message = " not specified") ->
        logger 2, "———— [Warning] ➔ Line #{line.naturalIndex}"
        logger 2, "—— [Cause] ➔ " .. message .. "\n"

    lineError: (line, message = " not specified") ->
        logger 2, "———— [Error] ➔ Line #{line.naturalIndex}"
        logger 0, "—— [Cause] ➔ " .. message .. "\n"

}
