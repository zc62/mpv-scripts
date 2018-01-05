-- mpv issue 5222
-- Automatically set loop-file=inf for duration < given length. Default is 5s
-- Use script-opts=autoloop-duration=x in mpv.conf to set your preferred length

local autoloop_duration = 5

function getOption()
    local opt = mp.get_opt("autoloop-duration")
    if (opt ~= nil) then
        local test = tonumber(opt)
        if (test ~= nil) then
            autoloop_duration = test
        end
    end
end
getOption()

local was_loop = mp.get_property_native("loop-file")

function set_loop()
    local duration = mp.get_property_native("duration")
    if duration ~= nil then
        if duration  < autoloop_duration + 0.001 then
            mp.command("set loop-file inf")
        else
            mp.set_property_native("loop-file", was_loop)
        end
    else
        mp.set_property_native("loop-file", was_loop)
    end
end

mp.register_event("file-loaded", set_loop)
