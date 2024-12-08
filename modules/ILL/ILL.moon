haveDepCtrl, DependencyControl, depctrl = pcall require, 'l0.DependencyControl'
local Aegi, Ass, Table, Logger
if haveDepCtrl
    depctrl = DependencyControl{
        name: "ILL",
        version: "2.0.0",
        description: "Module that eases the creation of macros",
        author: "ILLTeam",
        moduleName: "ILL.ILL",
        url: "https://github.com/TypesettingTools/ILL-Aegisub-Scripts",
        feed: "https://raw.githubusercontent.com/TypesettingTools/ILL-Aegisub-Scripts/main/DependencyControl.json",
        {
            "ILL.ILL.Aegi"
            "ILL.ILL.Ass.Ass"
            "ILL.ILL.Table"
            "ILL.ILL.Logger"
        }
    }
    Aegi, Ass, Table, Logger = depctrl\requireModules!
else
    Aegi = require "ILL.ILL.Aegi"
    Table = require "ILL.ILL.Table"
    Ass = require "ILL.ILL.Ass.Ass"
    Logger = require "ILL.ILL.Logger"

module = {
    :Aegi
    :Ass
    :Table
    :Logger
}


if haveDepCtrl
    module.version = depctrl
    return depctrl\register module
else
    return module
