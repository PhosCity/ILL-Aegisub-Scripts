module_version = "2.0.0"

haveDepCtrl, DependencyControl = pcall require, "l0.DependencyControl"

local depctrl
if haveDepCtrl
	depctrl = DependencyControl {
        -- TODO: Temporary name
		name: "ILL-dev"
		version: module_version
		description: "Module that eases the creation of macros."
		author: "ILLTeam"
		moduleName: "ILL.ILL"

        -- TODO: Temporarily commented
		-- url: "https://github.com/TypesettingTools/ILL-Aegisub-Scripts/"
		-- feed: "https://raw.githubusercontent.com/TypesettingTools/ILL-Aegisub-Scripts/main/DependencyControl.json"
		-- {
		-- 	{"ffi", "json"}
		-- 	{
		-- 		"clipper2.clipper2"
		-- 		version: "1.3.2"
		-- 		url: "https://github.com/TypesettingTools/ILL-Aegisub-Scripts/"
		-- 		feed: "https://raw.githubusercontent.com/TypesettingTools/ILL-Aegisub-Scripts/main/DependencyControl.json"
		-- 	}
		-- }
	}

import Aegi    from require "ILL.ILL.Aegi"
import Ass     from require "ILL.ILL.Ass.Ass"

modules = {
	:Aegi
	:Ass
	version: module_version
}

if haveDepCtrl
	depctrl\register modules
else
	modules
