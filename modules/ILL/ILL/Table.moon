{:insert, :remove} = table
local Table

Table = {

	-- checks if the table is empty
	isEmpty: (tb) -> next(tb) == nil

	-- check if the table is a list
	isList: (tb) -> return #tb == Table.size tb

	-- makes a shallow copy of the table
	shallowcopy: (tb) ->
		shallowcopy = (t) ->
			copy = {}
			if type(t) == "table"
				for k, v in pairs t
					copy[k] = v
			else
				copy = t
			return copy
		return shallowcopy tb

	-- makes a deep copy of the table
	deepcopy: (tb) ->
		deepcopy = (t, copies = {}) ->
			copy = {}
			if type(t) == "table"
				if copies[t]
					copy = copies[t]
				else
					copies[t] = copy
					for k, v in next, t, nil
						copy[deepcopy k, copies] = deepcopy v, copies
					setmetatable copy, deepcopy getmetatable(t), copies
			else
				copy = t
			return copy
		return deepcopy tb

	-- makes a copy of the table
	copy: (tb, deepcopy = true) -> deepcopy and Table.deepcopy(tb) or Table.shallowcopy(tb)

	-- apply a function to each value.
	map: (tb, callback) ->
		newTbl = {}
		for k, v in pairs tb
			newTbl[k] = callback(v, k)
		newTbl

	-- Keep only items that satisfy a condition
	filter: (tb, callback) ->
		newTbl = {}
		for k, v in pairs tb
			if callback(v, k)
				newTbl[k] = v
		newTbl

	-- Count the number of elements.
	size: (tb) ->
		count = 0
		for _ in pairs tb
			count += 1
		count

	-- Check if a value exists.
	contains: (tb, value) ->
		for _, v in pairs tb
			return true if v == value
		false

	-- Get the keys of the table
	keys: (tb) ->
		newTbl = {}
		for k in pairs tb
			insert newTbl, k
		newTbl

	-- count number of elements with specified value in an array
	count: (tb, callback) ->
		occurences = 0
		for k, v in pairs tb
			occurences += 1 if callback(v, k)
		occurences

	-- removes the element at the specified index
	-- removes last position if index is unspecified
	pop: (tb, index) ->
		remove tb, index
		return tb

	-- reverses the array values
	reverse: (tb) -> [tb[#tb + 1 - i] for i = 1, #tb]

	-- slices the array according to the given arguments
	slice: (tb, startIndex, endIndex, step) ->
		[tb[i] for i = startIndex or 1, endIndex or #tb, step or 1]
	
	-- join one or more arrays into an array
	extend: (tb, ... ) ->
		for tbl in *{...}
			table.move tbl, 1, #tbl, #tb + 1, tb
		tb

	-- deduplicates an array
	uniq: (tb) ->
		return Table.keys Table.makeSet tb

	-- returns the list containing elements only found in first list
	diff: (tb, ...) ->
		itemToRemove = {}
		for list in *{...}
			for item in *list
				itemToRemove[item] = true
		result = [item for item in *tb when not itemToRemove[item]]
		result

	-- returns the list containing elements found in all lists
	intersect: (tb, ...) ->
		tbSet = Table.makeSet tb

		for list in *{...}
			currentSet = {}
			for item in *list
				currentSet[item] = true if tbSet[item]
			tbSet = currentSet
			break if #currentSet == 0

		Table.keys tbSet

	-- remove all the indices of a list
	removeIndices: (tb, indices = {}) ->
		itemToRemove = Table.makeSet indices
		[item for i, item in ipairs(tb) when not itemToRemove[i]]

	-- remove a value from the list
	removeValues: (tb, value) ->
		if type(value) != "table"
			value = {value}

		valuesToRemove = Table.makeSet(value)
		[item for item in *tb when not valuesToRemove[item]]

	-- remove a value from the list
	makeSet: (tb) ->
		{key, true for key in *tb}

	-- inserts one or more values at the beginning of an array
	prepend: (tb, value) ->
		if type(value) != "table"
			value = {value}

		for i = #value, 1, -1
			insert tb, 1, value[i]
		tb

	-- changes the contents of a array, adding new elements while removing old ones
	splice: (tb, start, delete, ...) ->
		arguments, removes, t_len = {...}, {}, #tb
		n_args, i_args = #arguments, 1
		start = start < 1 and 1 or start
		delete = delete < 0 and 0 or delete
		if start > t_len
			start = t_len + 1
			delete = 0
		delete = start + delete - 1 > t_len and t_len - start + 1 or delete
		for pos = start, start + math.min(delete, n_args) - 1
			insert removes, tb[pos]
			tb[pos] = arguments[i_args]
			i_args += 1
		i_args -= 1
		for i = 1, delete - n_args
			insert removes, remove tb, start + i_args
		for i = n_args - delete, 1, -1
			insert tb, start + delete, arguments[i_args + i]
		return removes

	-- invert keys and values
	invert: (tb) ->
		{v, k for k, v in pairs tb}

	-- merge tables
	merge: (tb, ...) ->
		result = {}
		for key, value in pairs tb
			result[key] = value
		for t in *{...}
			for key, value in pairs t
				result[key] = value
		result

	-- Flattens a nested key-value table into a single level
	flatten: (tb, prefix = "") ->
		result = {}
		for key, value in pairs tb
			fullKey = "#{prefix}#{key}"
			if type(value) == "table"
				for k, v in pairs Table.flatten(value, "#{fullKey}.")
					result[k] = v
			else
				result[fullKey] = value
		result

	equal: (tb1, tb2) ->
		if type(tb1) != "table" or type(tb2) != "table"
			return false  -- one or both of them is not a table

		return true if tb1 == tb2  -- same table reference

		-- check keys and values in tb1
		for key, value1 in pairs tb1
			value2 = tb2[key]
			if type(value1) == "table" and type(value2) == "table"
				if not Table.equal value1, value2
					return false
			elseif value1 != value2
				return false

		-- check for any keys in tb2 not in tb1
		for key in pairs tb2
			return false unless tb1[key]

		true

	-- returns the contents of a table to a string
	view: (tb, table_name = "table_unnamed", indent = "") ->
		cart, autoref = "", ""
		basicSerialize = (o) ->
			so = tostring o
			if type(o) == "function"
				info = debug.getinfo o, "S"
				return string.format "%q", so .. ", C function" if info.what == "C"
				string.format "%q, defined in (lines: %s - %s), ubication %s", so, info.linedefined, info.lastlinedefined, info.source
			elseif (type(o) == "number") or (type(o) == "boolean")
				return so
			string.format "%q", so
		addtocart = (value, table_name, indent, saved = {}, field = table_name) ->
			cart ..= indent .. field
			if type(value) != "table"
				cart ..= ": " .. basicSerialize(value) .. "\n"
			else
				if saved[value]
					cart ..= ": {} -- #{saved[value]}(self reference)\n"
					autoref ..= "#{table_name} = #{saved[value]}\n"
				else
					saved[value] = table_name
					if Table.isEmpty value
						cart ..= ": {}\n"
					else
						cart ..= " = {\n"
						for k, v in pairs value
							k = basicSerialize k
							fname = "#{table_name}[ #{k} ]"
							field = "#{k}"
							addtocart v, fname, indent .. "	", saved, field
						cart = "#{cart}#{indent}}\n"
		return "#{table_name} = #{basicSerialize tb}" if type(tb) != "table"
		addtocart tb, table_name, indent
		return cart .. autoref

	}

return Table
