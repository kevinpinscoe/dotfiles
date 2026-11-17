-- ~/.hammerspoon/init.lua
--
-- Public configuration stored in dotfiles.
-- Private text phrases are stored separately in:
-- ~/.environment/phrases.txt

--------------------------------------------------
-- Current Clipboard Check
--------------------------------------------------

-- Shows what is on the clipboard right now, secrets in the
-- clear, via ~/bin/clipcheck.sh. Not for screen sharing.
-- Press again to dismiss; it also closes after 15 seconds.

local clipcheckScript = os.getenv("HOME") .. "/bin/clipcheck.sh"
local clipcheckAlert = nil

local function showClipboard()
  if clipcheckAlert then
    hs.alert.closeSpecific(clipcheckAlert)
    clipcheckAlert = nil
    return
  end

  local output = hs.execute("/bin/bash '" .. clipcheckScript .. "' 2>&1")

  clipcheckAlert = hs.alert.show(output, {
    textFont = "Menlo",
    textSize = 16,
    atScreenEdge = 0,
  }, hs.screen.mainScreen(), 15)

  local shown = clipcheckAlert
  hs.timer.doAfter(15, function()
    if clipcheckAlert == shown then clipcheckAlert = nil end
  end)
end

-- Control + V shows the current clipboard contents
hs.hotkey.bind({"ctrl"}, "v", function()
  showClipboard()
end)

--------------------------------------------------
-- Obsidian Fleeting Notes
--------------------------------------------------

-- Control + Option + N opens a new fleeting note
-- in the work-fleeting-notes vault

hs.hotkey.bind({"ctrl", "alt"}, "n", function()
  local name = os.date("%Y-%m-%d-%H%M%S")
  hs.urlevent.openURL(
    "obsidian://new?vault=work-fleeting-notes&name=" .. name
  )
end)

--------------------------------------------------
-- Private Text Phrases
--------------------------------------------------

local phrasesFile = os.getenv("HOME") ..
  "/.environment/phrases.txt"

-- Read a named phrase from the private file.
-- Format:
-- k=First phrase
-- b=Second phrase

local function getPhrase(key)
  local file, err = io.open(phrasesFile, "r")

  if not file then
    hs.alert.show("Cannot open private phrases file")
    print("Hammerspoon phrases: " .. tostring(err))
    return nil
  end

  for line in file:lines() do
    -- Ignore comments and blank lines
    if not line:match("^%s*#") and
       not line:match("^%s*$") then

      local name, value = line:match("^([%w_]+)=(.*)$")

      if name == key then
        file:close()
        return value
      end
    end
  end

  file:close()
  hs.alert.show("Phrase not found: " .. key)
  return nil
end

-- Insert the phrase without modifying the clipboard.

local function insertPhrase(key)
  local phrase = getPhrase(key)

  if phrase and phrase ~= "" then
    hs.eventtap.keyStrokes(phrase)
  end
end

-- Control + Option + K
hs.hotkey.bind({"ctrl", "alt"}, "k", function()
  insertPhrase("k")
end)

-- Control + Option + B
hs.hotkey.bind({"ctrl", "alt"}, "b", function()
  insertPhrase("b")
end)

-- Control + Option + W
hs.hotkey.bind({"ctrl", "alt"}, "w", function()
  insertPhrase("w")
end)
