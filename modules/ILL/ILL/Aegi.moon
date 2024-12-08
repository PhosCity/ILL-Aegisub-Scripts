Table = require "ILL.ILL.Table"

return {

    -- use loaded frame rate data to convert an absolute time given in milliseconds into a frame number
    ffm: (ms) -> aegisub.frame_from_ms ms

    -- use loaded frame rate data to convert a frame number of the video into an absolute time in milliseconds
    mff: (frame) -> aegisub.ms_from_frame frame

    -- the title that will appear on the progress screen
    progressTitle: (title) ->
        aegisub.progress.title title
        return

    -- the subtitle that will appear on the progress screen
    progressTask: (task = "") ->
        aegisub.progress.task task
        return

    -- the processing bar that ranges from 0 to 100
    progressSet: (i, n) ->
        aegisub.progress.set 100 * i / n
        return

    -- resets all progress
    progressReset: ->
        aegisub.progress.set 0
        aegisub.progress.task ""
        return

    -- checks if processing has been canceled and cancels
    progressCancelled: ->
        if aegisub.progress.is_cancelled!
            aegisub.cancel!

    -- Set the progress bar, task and check for user cancellation at once.
    progressLine: (line, i, n) ->
        aegisub.progress.set 100 * i / n
        aegisub.progress.task "Processing Line: #{line.naturalIndex} - #{i} / #{n}"
        if aegisub.progress.is_cancelled!
            aegisub.cancel!

    -- returns true if video is open in Aegisub
    videoIsOpen: ->
        if aegisub.project_properties!.video_file == ""
            return false
        return true

    -- returns framerate of the video
    getFramerate: ->
        if aegisub.project_properties!.video_file == ""
            return 24000 / 1001
        else
            ref_ms = 100000000                          -- 10^8 ms ~~ 27.7h
            refFrame = aegisub.frame_from_ms(ref_ms)
            framerate = refFrame * 1000 / ref_ms
            return framerate

}
