local function warn (t)
    if type (t) == 'table' then
        io.stderr:write (unpack(t) .. '\n')
    else
        io.stderr:write (t .. '\n')
    end
end

local function die (t)
    warn (t)
    os.exit (1)
end

local function defcback () end
local function deferror (str)
    die (string.format ("Error : undefined option %s", str))
end

local function apply (tab, func)
    for _, v in pairs (tab) do
        func (v)
    end
end

local function is_long (str)
    return str:len () > 1
end

local function to_match (str)
    if is_long (str) then
        return '--' .. str
    else
        return '-' .. str
    end
end

local function get_iterator (tab)
    local idx = 1
    local max = #tab
    return function ()
        if idx == max + 1 then
            return nil
        else
            idx = idx + 1
            return idx - 1, tab[idx - 1]
        end
    end
end

local function get_option (self, query)
    for _, item in ipairs (self) do
        for _, opt in pairs (item.opt) do
            if to_match (opt) == query then
                return item
            end
        end
    end
    return nil
end

local metaspec = {
    __index = {
        callback = defcback,
        need_arg = false,
    }
}

local function getopt (optspec, arg)
    if arg and type (arg) ~= "table" then
        warn ("Wrong type of argument, arg must be a table\n"
                  .. "fallback on _G.arg")
    end
    if not optspec or type (optspec) ~= "table" then
        warn ("Wrong type of argument, optspec must be a table")
    end

    apply (optspec, function (t) if type (t) == 'table' then
                   setmetatable (t, metaspec)
                   end end)
    setmetatable (optspec, {__index = {
                                get_option = get_option,
                                error = deferror
    }})

    local argv = arg or _G.arg

    local result = {}
    result.noarg = {}

    local continue_parse = true

    local it = get_iterator (argv)
    for _, value in it, argv do
        local opt = get_option (optspec, value)
        if opt == nil or not continue_parse then
            if value == '--' then
                continue_parse = false
            elseif value:match ("^(-).*") then
                optspec.error (value)
            else
                table.insert (result.noarg, value)
            end
        else
            if opt.need_arg then
                local _, arg = it ()
                if arg then
                    opt.callback (result, arg)
                else
                    die ("Option " .. value .. " needs an argument")
                end
            else
                opt.callback (result)
            end
        end
    end
    return result
end

return getopt
