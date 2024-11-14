# Nitpick ![GitHub stars](https://img.shields.io/github/stars/cupskrrtt/nitpick) ![License](https://img.shields.io/github/license/cupskrrtt/nitpick) ![Neovim version](https://img.shields.io/badge/Neovim-0.5+-green)

Nitpick is a lightweight and customizable linting plugin for Neovim. It allows you to easily integrate and configure linters for various programming languages. Nitpick searches both local project-based linters and global system-wide linters, ensuring that your linting tools are always available and consistent across all your projects.

> Note: This project currently supports linters commonly used in web development, such as `biome`, `eslint`, and `eslint_d`. You can add your own configuration by creating a PR!

## Motivation
I’ve never really been a fan of using linters, and whenever I tried one, it never quite worked the way I wanted. So, I decided to build my own Neovim plugin for linting—something that suits my style. I thought, why keep it to myself? Now, I’m sharing it with everyone in case it helps others have a smoother, more personalized linting experience!

Special thanks to the creator of nvim-lint for providing the foundation that made it possible for me to implement the Biome parser. I adapted some of his/her code to fit my needs, and it was a huge help in getting this plugin up and running.

## Features
- **Lightweight and Configurable**
- **Supports Project and Global Linters**
- **Flexible Linter Configuration**
- **Community Driven**

## Project Structure
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

## Setup

This example uses `lazy.nvim` as the package manager. If you use a different package manager, modify accordingly.

Nitpick runs in the background by default. To disable automatic linting, set `auto_lint` to `false` and run `NitpickLint` in neovim

### lazy.nvim Installation
```lua
return {
  "cupskrrtt/nitpick",
  config = function()
    require("nitpick").setup({
      linter_by_ft = {
        typescriptreact = { "eslint", "eslint_d", "biome" },
        javascriptreact = { "eslint", "eslint_d", "biome" },
        typescript = { "eslint", "eslint_d", "biome" },
        javascript = { "eslint", "eslint_d", "biome" },
      },
      auto_lint = false
    })
  end,
}
```
### packer Installation
```lua
use({
  "cupskrrtt/nitpick",
  config = function()
    require("nitpick").setup({
      linter_by_ft = {
        typescriptreact = { "eslint", "eslint_d", "biome" },
        javascriptreact = { "eslint", "eslint_d", "biome" },
        typescript = { "eslint", "eslint_d", "biome" },
        javascript = { "eslint", "eslint_d", "biome" },
      },
      auto_lint = false
    })
  end,
})
```
> Note: To identify the recognized filetype in Neovim, use :echo &filetype in the command line. Common filetypes in Neovim include typescriptreact (tsx) and javascriptreact (jsx).

## Customizing Linter Configurations

You can add or modify the configuration file for each linter. These files are located in lua/nitpick/linters. Simply open a new file and define your linter settings based on the examples provided.

## Usage

Nitpick automatically applies linting based on the configured file types when files are opened or saved. To manually trigger linting, use the following command in Neovim:
```vim
:NitpickLint
```

Nitpick also capable to send the lint and diagnostic data to the quickfix list, use the following command:
```vim
:NitpickQuickFix
```

## Example Output
When `Nitpick` runs, it highlights errors and warnings directly in the code. Here’s a sample of what you might see:
> [eslint] 'x' is assigned a value but never used. (no-unused-vars) 

> [biome] Unexpected console statement. (no-console)
All linting issues are displayed in the quickfix or location list, allowing you to quickly navigate between them.


## Contribution

Contributions are welcome! If you have suggestions, please create an issue. If you want to contribute directly, feel free to submit a PR.

### Setting up for Development

1. Fork the repository and clone it locally.
2. Install the plugin using package manager from directory
3. Open Neovim and load `nitpick` in development mode to test your changes.

### Adding a New Linter

To add a new linter:
1. Create a new file in the `lua/nitpick/linters` directory, e.g., `my_linter.lua`.
2. Follow the structure in `eslint.lua` or `biome.lua` for consistent configuration.
3. Test your linter integration by running Neovim with `Nitpick` enabled on the desired file type.

Once you’re ready, open a PR with your changes. Be sure to follow the coding style and include any necessary documentation updates.
