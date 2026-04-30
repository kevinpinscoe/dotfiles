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
