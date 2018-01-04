// Issue mpv-player/mpv#5330
// Generate a temp screenshot file on desktop then copy to clipboard. (Windows only)
// nircmd is required: http://www.nirsoft.net/utils/nircmd.html
//
// script option: ss-2-cb-nircmdc="nircmdc"
//     Path to nircmdc executable file.
//     If not set, nircmdc will be searched in Windows PATH variable.
//
// Example: mpv file.mkv --script-opts=ss-2-cb-nircmdc="C:\nircmd\nircmdc.exe"

var nircmdc = "nircmdc";

function getOption()
{
    var opt = mp.get_opt("ss-2-cb-nircmdc");
    if (opt)
        nircmdc = opt;
}
getOption();

var ss_file = mp.utils.get_user_path("~~desktop/mpv-ss-2-cb.png");

function ss_2_cb()
{
    mp.commandv("osd-msg", "screenshot-to-file", ss_file);
    mp.utils.subprocess_detached({"args" : [nircmdc, "clipboard", "copyimage",
        ss_file]});
}

function ss_2_cb_video()
{
    mp.commandv("osd-msg", "screenshot-to-file", ss_file, "video");
    mp.utils.subprocess_detached({"args" : [nircmdc, "clipboard", "copyimage",
        ss_file]});
}

function ss_2_cb_window()
{
    mp.commandv("osd-msg", "screenshot-to-file", ss_file, "window");
    mp.utils.subprocess_detached({"args" : [nircmdc, "clipboard", "copyimage",
        ss_file]});
}

mp.add_key_binding("s", "screenshot-to-clipboard", ss_2_cb);
mp.add_key_binding("S", "screenshot-to-clipboard_video", ss_2_cb_video);
mp.add_key_binding("ctrl+s", "screenshot-to-clipboard_window", ss_2_cb_window);
