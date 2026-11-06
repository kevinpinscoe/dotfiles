-- ~/.hammerspoon/init.lua

local function openSpotlightClipboard()
  hs.eventtap.keyStroke({"cmd"}, "space")

  hs.timer.doAfter(0.15, function()
    hs.eventtap.keyStroke({"cmd"}, "4")
  end)
end

-- Control + V opens Spotlight Clipboard History
hs.hotkey.bind({"ctrl"}, "v", function()
  openSpotlightClipboard()
end)

-- Control + Option + N opens a new fleeting note in the work-fleeting-notes vault
hs.hotkey.bind({"ctrl", "alt"}, "n", function()
  local name = os.date("%Y-%m-%d-%H%M%S")
  hs.urlevent.openURL("obsidian://new?vault=work-fleeting-notes&name=" .. name)
end)
