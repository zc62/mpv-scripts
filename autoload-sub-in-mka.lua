-- Load mka files as sub files.
-- Respect sub-auto, sub-file-paths and audio-file-paths options.

mputils = require 'mp.utils'

-- Followings are from:
-- https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autoload.lua
function get_extension(path)
    match = string.match(path, "%.([^%.]+)$" )
    if match == nil then
        return "nomatch"
    else
        return match
    end
end

table.filter = function(t, iter)
    for i = #t, 1, -1 do
        if not iter(t[i]) then
            table.remove(t, i)
        end
    end
end

-- splitbynum and alnumcomp from alphanum.lua (C) Andre Bogus
-- Released under the MIT License
-- http://www.davekoelle.com/files/alphanum.lua

-- split a string into a table of number and string values
function splitbynum(s)
    local result = {}
    for x, y in (s or ""):gmatch("(%d*)(%D*)") do
        if x ~= "" then table.insert(result, tonumber(x)) end
        if y ~= "" then table.insert(result, y) end
    end
    return result
end

function clean_key(k)
    k = (' '..k..' '):gsub("%s+", " "):sub(2, -2):lower()
    return splitbynum(k)
end

-- compare two strings
function alnumcomp(x, y)
    local xt, yt = clean_key(x), clean_key(y)
    for i = 1, math.min(#xt, #yt) do
        local xe, ye = xt[i], yt[i]
        if type(xe) == "string" then ye = tostring(ye)
        elseif type(ye) == "string" then xe = tostring(xe) end
        if xe ~= ye then return xe < ye end
    end
    return #xt < #yt
end
------------------------------------------------------------------ END

function get_filename(path, sub_auto)
    if sub_auto == "exact" then
        match = string.match(path, "^(.+)%.")
    else -- fuzzy. When sub_auto=all, return identical value to fuzzy
        match = string.match(path, "^([^%.]+)%.")
    end
    if match == nil then
        return "nomatch"
    else
        return match
    end
end

function autoload_sub_in_mka()
    local sub_auto = mp.get_property("options/sub-auto", "")
    if sub_auto == "no" then
        return
    end

    local path = mp.get_property("path", "")
    local dir, filename = mputils.split_path(path)
    if #dir == 0 then
        return
    end
    local filename_wo_ext = mp.get_property("filename/no-ext", "")

    local files = mputils.readdir(dir, "files")
    if files == nil then
        return
    end

    local audio_file_paths = mp.get_property_native("options/audio-file-paths", {})
    local sub_file_paths = mp.get_property_native("options/sub-file-paths", {})

    local sub_files = mp.get_property_native("sub-files", {})

    -- in current dir
    table.filter(files, function (v, k)
        if string.match(v, "^%.") then
            return false
        end
        if sub_auto ~= "all" and get_filename(v, sub_auto) ~= filename_wo_ext then
            return false
        end
        local ext = get_extension(v)
        if string.lower(ext) ~= "mka" then
            return false
        end
        return true
    end)
    table.sort(files, alnumcomp)

    for i = 1, #files do
        local file = mputils.join_path(dir, files[i])
        table.insert(sub_files, file)
        mp.msg.info("Adding as subtitle files: " .. file)
    end

    -- in sub-file-paths
    for i = 1, #sub_file_paths do
        local sub_file_path = mputils.join_path(dir, sub_file_paths[i])
        local files = mputils.readdir(sub_file_path, "files")
        if files == nil then
            break
        end
        table.filter(files, function (v, k)
            if string.match(v, "^%.") then
                return false
            end
            if sub_auto ~= "all" and get_filename(v, sub_auto) ~= filename_wo_ext then
                return false
            end
            local ext = get_extension(v)
            if string.lower(ext) ~= "mka" then
                return false
            end
            return true
        end)
        table.sort(files, alnumcomp)

        for j = 1, #files do
            local file = mputils.join_path(sub_file_path, files[j])
            table.insert(sub_files, file)
            mp.msg.info("Adding as subtitle files: " .. file)
        end
    end

    -- in audio-file-paths, this script respects sub-auto=all as sub-auto=fuzzy
    for i = 1, #audio_file_paths do
        local audio_file_path = mputils.join_path(dir, audio_file_paths[i])
        local files = mputils.readdir(audio_file_path, "files")
        if files == nil then
            break
        end
        table.filter(files, function (v, k)
            if string.match(v, "^%.") then
                return false
            end
            -- no sub_auto ~= "all" here because even if sub-auto=all,
            -- one should not expect all mka files in audio-file-paths to be
            -- loaded as subtitle files
            if get_filename(v, sub_auto) ~= filename_wo_ext then
                return false
            end
            local ext = get_extension(v)
            if string.lower(ext) ~= "mka" then
                return false
            end
            return true
        end)
        table.sort(files, alnumcomp)

        for j = 1, #files do
            local file = mputils.join_path(audio_file_path, files[j])
            table.insert(sub_files, file)
            mp.msg.info("Adding as subtitle files: " .. file)
        end
    end

    mp.set_property_native("sub-files", sub_files)
end

mp.register_event("start-file", autoload_sub_in_mka)
