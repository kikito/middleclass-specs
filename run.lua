#!/usr/bin/env lua

local package_path = "package.path = './middleclass/?.lua'"
os.execute( string.format("tsc -f --before=%q *_spec.lua", package_path ) )
