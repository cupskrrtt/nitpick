# NITPICK (WIP)

Nitpick is a lightweight and customizable linting plugin for Neovim. It allows you to easily integrate and configure linters for various programming languages. Nitpick searches both local project-based linters and global system-wide linters, ensuring that your linting tools are always available and consistent across all your projects. 

>> Note this project only support linter used in web dev e.g. biomejs, eslint, and eslint_d you can add you own config file for the linter just open a PR :)

# Project structure

```
.
├── lua
│   └── nitpick
│       ├── init.lua            # Entry point
│       ├── linters             # The folder containing linter config file
│       │   ├── biome.lua
│       │   └── eslint.lua
│       ├── types.lua           # Used types
│       └── util.lua
├── plugin                  
│   └── nitpick.vim             # Needed for the plugin to be used
└── README.md
```

# Setup

The setup provided is using lazy.nvim if you use another package manager set it to the equivalent

```lua
return {
  "cupskrrtt/nitpick",
  config = function()
    require("nitpick").setup({
      linter_by_ft = {
        typescriptreact = { "eslint", "eslint_d", "biome" },
        javascript = { "eslint", "prettier" },
        python = { "flake8", "pylint" },
      }
    })
  end,
}
```

if you don't know the filetype recognized by nvim you can use this command in neovim command line
```
:echo &filetype
```

AFAIK the filetype that is recognized different in nvim are

```
typescriptreact = tsx
javascriptreact = jsx
```

# Contribution

If you have any idea to improve please create an issue or you want to get involved directly you can just create a PR :)

Thanks!!!!!


## TODO
- [ ] add other linter

