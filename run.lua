#!/usr/bin/env lua

local package_path_command = "package.path = '?.lua;lib/?.lua;lib/?/init.lua;' .. package.path"
os.execute( ("tsc -f --before=%q core_*.lua extras_*.lua"):format( package_path_command ) )
