Aegi = require "ILL.ILL.Aegi"
Table = require "ILL.ILL.Table"
Math = require "ILL.ILL.Math"
Logger = require "ILL.ILL.Logger"


class Ass
    set: (@sub, @sel, @activeLine, @collectionCallback) =>
        -- gets meta and styles values
        @collectHead!

        -- Initiate table here
        @linesToInsert = {}

        -- sets the selection information
        if not @sel or type(@sel) != "table" or #@sel == 0
            @sel = {}

            for l, i in @iterSub!
                continue unless l.class == "dialogue"
                table.insert @sel, i

        @collectLines!


    new: (...) => @set ...


    collectLines: (@collectionCallback = ( line ) -> return not line.comment) =>
        @lines = {}
        firstDialogueIndex = 0

        for l, i in @iterSub!
            continue unless l.class == "dialogue"
            firstDialogueIndex = i
            break

        for i = 1, #@sel
            index = @sel[i]
            line = @sub[index]
            continue unless @collectionCallback line

            line.absoluteIndex = index
            line.naturalIndex = index - firstDialogueIndex + 1

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
    iterLines: (callback, reverse, copy) =>
        startIndex, endIndex, increment = 1, #@lines, 1
        if reverse
            startIndex, endIndex, increment =  #@lines, 1, -1

        for i = startIndex, endIndex, increment
            line = @lines[i]
            continueIteration = callback(
                copy and Table.deepcopy(line) or line,
                reverse and startIndex - i + 1 or i,
                #@lines
            )
            break if continueIteration == false


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

        Logger.debug "ILL: Video X correction factor = %f\n\n", @meta.video_x_correct_factor
        return @


    -- Mark lines for removal
    removeLine: (line) =>
        line.toRemove = true


    -- Mark lines for insertion
    insertLine: (line, index) =>
        line.toInsert = true
        line.insertIndex = index and index or math.huge
        table.insert @linesToInsert, line


    -- Commit lines to subtitle object.
    -- Removes lines marked for removal.
    -- Inserts lines marked for insertion at the index where it was inserted to by user. If insertion index is not marked, it appends after the selection.
    -- It modifies the line in the subtitle objected that were modified by the user.
    -- If updateRefs is true, it recollects the line with updated parameters.
    commit: (updateRefs = false)=>
        if #@linesToInsert > 0
            for i, line in ipairs @linesToInsert
                line.i = i
                insertIndex = Math.clamp(line.insertIndex, 1, #@lines)
                line.insertIndex = insertIndex
                line.absoluteIndex = @lines[insertIndex].absoluteIndex

            table.sort @linesToInsert, (a, b) ->
                return (a.absoluteIndex < b.absoluteIndex) or (a.absoluteIndex == b.absoluteIndex) and (a.i < b.i)

            for i, line in ipairs @linesToInsert
                table.insert @lines, line.insertIndex + i, line

            local prevLineIndex
            for line in *@lines
                if prevLineIndex
                    line.absoluteIndex = prevLineIndex + 1
                prevLineIndex = line.absoluteIndex
                -- line.absoluteIndex = prevLineIndex

        linesToRemove = {}
        for line in *@lines
            if line.toInsert
                @sub.insert line.absoluteIndex, line
                table.insert @sel, @sel[#@sel] + 1
            elseif line.toRemove
                table.insert linesToRemove, line.absoluteIndex
            else
                @sub[line.absoluteIndex] = line

        if #linesToRemove > 0
            @sub.delete linesToRemove
            for i =1, #linesToRemove
                Table.pop @sel

        if updateRefs
            @collectLines!

    -- Get selected lines
    getSelection: =>
        @sel


Ass

