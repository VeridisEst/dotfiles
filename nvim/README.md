# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

Also: the website [lazyvim.org](https://www.lazyvim.org/)

## What I did

It's not very different frome the standard, don't get me wrong. I mainly added a plugin, but it's mine and I don't like change.
Also it may change in the future. Who knows! 

## How to use 
- Install the latest version of nvim, this requires at least 0.9 <br> 
`https://github.com/neovim/neovim` has instructions
- Make a backup of your current Neovim files
### required
`mv ~/.config/nvim %your backup path%`
### optional but recommended
`mv ~/.local/share/nvim %your backup path%` <br>
`mv ~/.local/state/nvim %your backup path%` <br>
`mv ~/.cache/nvim %your backup path%` <br>
- Clone the starter <br> 
`git clone https://github.com/LazyVim/starter ~/.config/nvim`
- Remove the `.git` folder so you can copy it like this yourself later <br> 
`rm -rf ~/.config/nvim/.git`
- Start Neovim! <br> 
`nvim`
- It should look different already! <br>
If not: check your steps
- Ignore all the errors in vim
> NOTE: If you have any errors before this that are in your command line, google the errors, they are not part of this guide. All errors should be in vim itself.
- Close vim <br>
If stuck in lazy.vim, just press `q` a couple of times <br>
If stuck in vim, use `esc :q!`
- Download only this folder <br> 
`git clone --filter=blob:none --sparse https://github.com/VeridisEst/dotfiles` <br>
`cd dotfiles` <br>
`git sparse-checkout add nvim` <br>
`cp -r nvim ~/.config/nvim` 
- Succes!
  
Why the complicated git clone? <br>
I wanted to be able to download just this github folder: `/dotfiles/nvim` and not everything <br> 
Well, this downloads the entire repo, but only metadata, so it doesn't take space or bandwith <br> 
and then it downloads only the nvim folder! <br> 
Great success! 
