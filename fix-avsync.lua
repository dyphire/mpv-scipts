--[[
    Fixed video freezing caused when switching audio tracks.
    available at: https://github.com/dyphire/mpv-scripts
]]--

local mp = require "mp"
local msg = require "mp.msg"

local function fix_avsync()
    local paused = mp.get_property_native("pause")
    local muted = mp.get_property_native("mute")
    local vid = mp.get_property_number("vid")
    local image = mp.get_property_native("current-tracks/video/image", false)
    local albumart = image and mp.get_property_native("current-tracks/video/albumart", false)

    if not vid or image or albumart then return end
    msg.info("fix A/V sync.")
    mp.commandv("frame-step")
    mp.set_property_native("mute", true)
    mp.add_timeout(0.1, function()
        mp.commandv("frame-back-step")
        if paused then return
        else mp.set_property_native("pause", false) end
    end)
    mp.add_timeout(0.5, function()
        if muted then return
        else mp.set_property_native("mute", false) end
    end)
end

mp.register_event("file-loaded", function()
    mp.observe_property("aid", "number", function(_, aid)
        if aid then fix_avsync() end
    end)
end)

mp.register_event("end-file", function()
    mp.unobserve_property(fix_avsync)
end)
