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

-- This is the property after the script is loaded. Global config
local was_loop = mp.get_property_native("loop-file")
local changed = false

function set_loop()
    local duration = mp.get_property_native("duration")
    -- Check the property again in case auto profiles (e.g., extensions.gjf)
    -- have changed it since the script is loaded
    was_loop = mp.get_property_native("loop-file")
    if duration ~= nil and was_loop ~= true then
        if duration < autoloop_duration + 0.001 then
            mp.command("set loop-file inf")
            changed = true
        end
    end
end

function reset_loop()
    -- I need this hack because the "end-file" event is often accompanied by
    -- the loading process of the next file in the playlist. If the
    -- "loop-file" property is already changed by auto profiles (e.g.,
    -- extensions.gjf), then do not try to reset this property
    local status = mp.get_property_native("loop-file")
    if changed and status == true then
        mp.set_property_native("loop-file", was_loop)
        changed = false
    end
end

mp.register_event("file-loaded", set_loop)
mp.register_event("end-file", reset_loop)
