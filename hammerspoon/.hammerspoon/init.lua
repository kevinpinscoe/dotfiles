-- ~/.hammerspoon/init.lua
--
-- Public configuration stored in dotfiles.
-- Private text phrases are stored separately in:
-- ~/.environment/phrases.txt

--------------------------------------------------
-- Spotlight Clipboard History
--------------------------------------------------

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
