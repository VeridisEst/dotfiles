# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

Also: the website [lazyvim.org](https://www.lazyvim.org/)

## What I did

It's not very different frome the standard, don't get me wrong. I mainly added a plugin, but it's mine and I don't like change.
Also it may change in the future. Who knows! 

## How to use 

- Make a backup of your current Neovim files
### required
`mv ~/.config/nvim{,.bak}`
### optional but recommended
`mv ~/.local/share/nvim{,.bak}` <br>
`mv ~/.local/state/nvim{,.bak}` <br>
`mv ~/.cache/nvim{,.bak}` <br>
- Clone the starter <br> 
`git clone https://github.com/LazyVim/starter ~/.config/nvim`
- Remove the `.git` folder so you can copy it like this yourself later <br> 
`rm -rf ~/.config/nvim/.git`
- Start Neovim! <br> 
`nvim`
- Ignore all the errors
- Download only this folder <br> 
`git clone --filter=blob:none --sparse https://github.com/VeridisEst/dotfiles` <br>
`cd dotfiles` <br>
`git sparse-checkout add nvim` <br>
`cp nvim ~/.config/nvim` 
- Succes! 
