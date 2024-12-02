import Aegi  from require "ILL.ILL.Aegi"

class Ass

	set: (@sub, @sel, @activeLine, @remLine = true) =>
		-- sets the selection information
		@i, @fi, @newSelection = 0, 0, {}
		for l, i in @iterSub!
			if l.class == "dialogue"
				-- number of the first line of the dialog
				@fi = i
				break
		-- gets meta and styles values
		@collectHead!

	new: (...) => @set ...

	-- iterates over all the lines of the ass file
	iterSub: (copy) =>
		i = 0
		n = #@sub
		->
			i += 1
			if i <= n
				l = @sub[i + @i]
				if l.class == "dialogue"
					l.isShape = Util.isShape l.text
				if copy
					if l.class == "dialogue"
						line = Table.deepcopy l
						unless l.isShape
							line.text = Text line.text, line.isShape
					return l, line, i, n
				return l, i, n

	-- iterates over all the selected lines of the ass file
	iterSel: (copy) =>
		i = 0
		n = #@sel
		->
			i += 1
			if i <= n
				s = @sel[i]
				l = @sub[s + @i]
				l.isShape = Util.isShape l.text
				if copy
					line = Table.deepcopy l
					unless l.isShape
						line.text = Text line.text, line.isShape
					return l, line, s, i, n
				return l, s, i, n

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
				if .res_x == 0 and _res_y == 0
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

{:Ass}
