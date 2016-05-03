set nocompatible  	" vim > vi
filetype off		

"Include vundle in runtime path

set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()

"Let vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'


"Add plugins here, brief docs below
Plugin 'tpope/vim-fugitive' 		" Git wrapper
Plugin 'wincent/command-t'		" File navigation
Plugin 'scrooloose/syntastic'		" Syntax checking
Plugin 'tpope/vim-surround'		" Bracketing tool
Plugin 'bling/vim-airline'		" Powerful infobar 
Plugin 'scrooloose/nerdcommenter'	" Commenting tool - \cc \cn \c\
Plugin 'easymotion/vim-easymotion'	" Jump around text
Plugin 'valloric/youcompleteme' 	" Autocomplete at its best
Plugin 'ctrlpvim/ctrlp.vim'		" Fuzzy file, buffer, mru, tag finder
Plugin 'altercation/vim-colors-solarized'
Plugin 'haya14busa/incsearch.vim'
Plugin 'haya14busa/incsearch-fuzzy.vim'
Plugin 'c9s/perlomni.vim'

"vim-surround:
"Change brackets - cs<current><target> : cs'"
"Bracket word - ysiw[
"Use closing bracket to parenthesize with a space : ysiw] changes hi to [ hi ] 
"

"nerdcommenter:
"Comment out line \cc or selected text
"Force nesting \cn
"Toggle comment \c\
"Sexy comment \cs
"Toggles commenting line by line \ci
"Add comment to end of line \cA

call vundle#end()

filetype plugin indent on

"Set colorscheme
syntax enable
set background=dark
let g:solarized_termtrans = 1
colorscheme solarized


"Enable mouse, its $CURRENT_YEAR, use your mouse fool
set mouse=a

"Other customizations
let mapleader = "\<Space>"		" Map leader to spacebar
nnoremap <Leader>o :CtrlP<CR> 		" Open file with space+o
nnoremap <Leader>w :w<CR>		" Save with space+w
nnoremap <Leader>q :q<CR>
nnoremap <Leader>x :x<CR>

" Copy and paste with leader easier
vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P

" Easymotion with fuzzy search
function! s:config_easyfuzzymotion(...) abort
	  return extend(copy({
	    \   'converters': [incsearch#config#fuzzyword#converter()],
	    \   'modules': [incsearch#config#easymotion#module({'overwin': 1})],
	    \   'keymap': {"\<CR>": '<Over>(easymotion)'},
	    \   'is_expr': 0,
	    \   'is_stay': 1
	    \ }), get(a:, 1, {}))
  endfunction

  noremap <silent><expr> <Space>/ incsearch#go(<SID>config_easyfuzzymotion())

" Configure syntastic with recommended settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Alt + Direction to navigate window splits
nmap <silent> <A-Up> :wincmd k<CR>
nmap <silent> <A-Down> :wincmd j<CR>
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>
