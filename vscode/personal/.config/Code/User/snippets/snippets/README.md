# VS Code User Snippets

This directory contains user-defined code snippets for Visual Studio Code.

## What are snippets?

Snippets are reusable templates that expand into commonly used text or code. They help reduce repetitive typing and standardize patterns such as:

* Markdown links
* Code blocks
* Function templates
* Loops or conditionals

A snippet typically includes:

* **prefix**: the trigger text you type
* **body**: the content inserted when expanded
* **description**: optional explanation of the snippet

Example snippet:

```json
{
  "Markdown Link": {
    "prefix": "mdlink",
    "body": ["[$1]($2)"],
    "description": "Insert a markdown link"
  }
}
```

Typing `mdlink` and selecting the snippet will insert a Markdown link template.

## File structure

Snippets are stored as JSON files in this directory. Common patterns include:

* Language-specific files:

  * `markdown.json`
  * `python.json`
  * `javascript.json`

* Global snippets:

  * `*.code-snippets`

## Notes

* Snippets are separate from editor settings.
* Editor settings are stored in:

  ```
  ~/.config/Code/User/settings.json
  ```
* Snippets are best managed through VS Code using:

  ```
  Snippets: Configure User Snippets
  ```

  from the Command Palette.

## Important distinction

* `settings.json` → editor configuration
* snippet files → reusable text/code templates

Only valid JSON snippet files should be used for snippet definitions in this directory.

## Python example

File would be ~/.config/Code/User/snippets/python.json

```
{
  "Python Main Guard": {
    "prefix": "pymain",
    "body": [
      "def main():",
      "    ${1:pass}",
      "",
      "if __name__ == \"__main__\":",
      "    main()"
    ],
    "description": "Python main entry point"
  },

  "Print Debug": {
    "prefix": "pdbg",
    "body": [
      "print(f\"${1:var} = {${1:var}}\")"
    ],
    "description": "Formatted debug print"
  },

  "Try Except": {
    "prefix": "pytry",
    "body": [
      "try:",
      "    ${1:pass}",
      "except ${2:Exception} as ${3:e}:",
      "    ${4:print(e)}"
    ],
    "description": "Try/except block"
  }
}
```

### Usage:

Usage:

Open a .py file
Type the prefix (e.g., pymain)
Press Tab or select the snippet from IntelliSense

Notes:

File must be valid JSON
Name must match the language (python.json for Python)
Multiple snippets can exist in one file
