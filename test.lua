require 'pl'
local getopt = require "getopt"
local res = getopt {
    {opt = {'h', 'help'}, callback = function (t) t.h = true end},
    {opt = {'v', 'vi-vi'}, callback = function (t, v) t.v = v end, need_arg = true},
}

pretty.dump (res)
