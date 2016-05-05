# Muh Scripts

### 1. PrintQueueTool.sh
   A script modified from the [original one](http://itsc.ust.hk/kb/article-504.html) provided by the ITSC department at HKUST to install and manage University Satellite and Barn printers. The original only works for init based systems such as Ubuntu. This works for OSes configured with systemd such as Fedora, Arch or CentOS. 
### 2. .vimrc
   My beloved vim configuration. Uses vundle and the following packages:
   -  [vim-fugitive](https://github.com/tpope/vim-fugitive)
   -  [command-t](https://github.com/wincent/command-t)
   -  [syntastic](https://github.com/scrooloose/syntastic)
   -  [vim-surround](https://github.com/tpope/vim-surround)
   -  [vim-airline](https://github.com/bling/vim-airline)
   -  [nerdcommenter](https://github.com/scrooloose/nerdcommenter)
   -  [vim-easymotion](https://github.com/easymotion/vim-easymotion)
   -  [YouCompleteMe](https://github.com/valloric/youcompleteme)
   -  [CtrlP](https://github.com/ctrlpvim/ctrlp.vim)
   -  [solarized](https://github.com/altercation/vim-colors-solarized)
   -  [incsearch](https://github.com/haya14busa/incsearch.vim)
   -  [incsearch-fuzzy](https://github.com/haya14busa/incsearch-fuzzy.vim)
   -  [perlomni](https://github.com/c9s/perlomni.vim)

   Installation instructions:
   ```
   #install Vundle
   $ git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
   # backup current config
   $ mv .vimrc .vimrc.backup
   # grab my config
   $ wget https://raw.githubusercontent.com/arvind-iyer/personal-scripts/master/.vimrc
   # install requirements for YCM
   $ sudo apt-get install build-essential cmake python-dev python3-dev
   # compile youcompleteme
   $ cd ~/.vim/bundle/YouCompleteMe
   $ ./install.py --clang-completer --tern-completer
   ```
   
   Finally open up vim and run *:PluginInstall*
