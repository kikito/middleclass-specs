#!/usr/bin/env lua

local package_path = "package.path = '?.lua;?/init.lua;'"
os.execute( string.format("tsc -f --before=%q core_*.lua extras_*.lua", package_path ) )
