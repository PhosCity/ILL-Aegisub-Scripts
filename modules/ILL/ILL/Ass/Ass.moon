Aegi = require "ILL.ILL.Aegi"
Table = require "ILL.ILL.Table"

class Ass

    set: (@sub, @sel, @activeLine, callback) =>
        -- gets meta and styles values
        @collectHead!

        -- sets the selection information
        @lines = {}
        if not @sel or type(@sel) != "table" or #@sel == 0
            @sel = {}

            for l, i in @iterSub!
                continue unless l.class == "dialogue"
                table.insert @sel, i

        @collectLines callback


    new: (...) => @set ...


    collectLines: (callback = ( line ) -> return not line.comment) =>
        firstDialogueIndex = 0

        for l, i in @iterSub!
            continue unless l.class == "dialogue"
            firstDialogueIndex = i
            break

        for i = 1, #@sel
            index = @sel[i]
            line = @sub[index]
            continue unless callback line

            line.index = index
            line.dialogueIndex = index - firstDialogueIndex + 1
            line.duration = line.end_time - line.start_time
            line.styleRef = @styles[line.style]

            if Aegi.videoIsOpen!
                line.startFrame = Aegi.ffm line.start_time
                line.endFrame = Aegi.ffm line.end_time
                line.frameCount = line.endFrame - line.startFrame

            table.insert @lines, line


    -- iterates over all the lines of the ass file
    iterSub: (copy) =>
        i = 0
        ->
            i += 1
            if i <= #@sub
                l = @sub[i]
                if copy
                    line = Table.deepcopy l
                    return line, i
                return l, i


    -- iterates over all the selected lines of the ass file
    iterSel: (callback, reverse, copy) =>
        startIndex, endIndex, increment = 1, #@lines, 1
        if reverse
            startIndex, endIndex, increment =  #@lines, 1, -1

        for i = startIndex, endIndex, increment
            line = @lines[i]
            callback line, line.index, reverse and endIndex - i + 1 or i, #@lines


    -- gets the meta and styles values from the ass file
    collectHead: =>
        @meta, @styles = {res_x: 0, res_y: 0, video_x_correct_factor: 1}, {}
        for l in @iterSub!
            if aegisub.progress.is_cancelled!
                error "User cancelled", 2

            if l.class == "style"
                @styles[l.name] = l
            elseif l.class == "info"
                @meta[l.key\lower!] = l.value
            else
                break

        -- check if there are any styles present in the ass file
        if Table.isEmpty @styles
            error "ERROR: No styles were found in the file, bug?!", 2

        -- fix resolution data
        with @meta
            if pcall -> @sub.script_resolution
                .res_x, .res_y = @sub.script_resolution!
            else
                if .playresx
                    .res_x = math.floor .playresx
                if .playresy
                    .res_y = math.floor .playresy
                if .res_x == 0 and .res_y == 0
                    .res_x = 384
                    .res_y = 288
                elseif .res_x == 0
                    if .res_y == 1024
                        .res_x = 1280
                    else
                        .res_x = .res_y / 3 * 4
                elseif .res_y == 0
                    if .res_x == 1280
                        .res_y = 1024
                    else
                        .res_y = .res_x * 3 / 4

        video_x, video_y = aegisub.video_size!
        if video_y
            @meta.video_x_correct_factor = (video_y / video_x) / (@meta.res_y / @meta.res_x)

        Aegi.debug 4, "ILL: Video X correction factor = %f\n\n", @meta.video_x_correct_factor
        return @


Ass

