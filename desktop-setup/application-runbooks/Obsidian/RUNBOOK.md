# Runbook for Using Obsidian

## Managing the Spelling Dictionary

### Where the dictionary file lives

```
~/.config/obsidian/Custom Dictionary.txt
```

### How to remove accidentally added misspelled words

1. Close Obsidian completely before editing the file.
2. Open the file in a text editor.
3. Delete the line containing the misspelled word. Each word is on its own line.
4. Do **not** edit the checksum line at the bottom — leave it as-is.
5. Save the file, then reopen Obsidian.

Obsidian will detect the checksum mismatch on startup, accept the updated word list, and rewrite the checksum automatically.

### About the checksum

The last line of the dictionary file looks like:

```
checksum_v1 = bb4b5124a3bc59dc139b708d79709ec3
```

This is generated and maintained by Obsidian. Do not manually update it — the algorithm Obsidian uses is not a plain MD5 of the word list, so any value you calculate yourself will be wrong. Obsidian reconciles and rewrites the checksum on the next launch after it detects a mismatch.
