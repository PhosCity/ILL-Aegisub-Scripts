Table = require "ILL.ILL.Table"
Math = require "ILL.ILL.Math"
Logger = require "ILL.ILL.Logger"

parse_tags = (rawTags) ->
    tags = {}
    for tag in rawTags\gmatch "\\[^\\]+"
        tags[#tags + 1] = tag
    tags


class Line

    new: (line, section) => 
        @sections = {}

        text = line.text
        index = 0

        for content, braceContent in text\gmatch "(.-){((.-))}" do
            if #content > 0                                                         --Text exists before the brace
                index += 1
                table.insert @sections, { index: index, text: content }

            if braceContent
                tags = parse_tags braceContent
                if #tags > 0
                    index += 1
                    table.insert @sections, { index: index, tags: tags }
                else
                    index += 1
                    table.insert @sections, { index: index, comment: braceContent }

        -- The last text/drawing section
        lastSection = text\match "[^}]*$"
        if #lastSection > 0
            index += 1
            table.insert @sections, { index: index, text: remaining }

        @sections


Line
