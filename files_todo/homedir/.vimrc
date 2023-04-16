set nocompatible

" Auto Install vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Must be before plugin is loaded
let g:ale_completion_enabled = 1
set omnifunc=ale#completion#OmniFunc

call plug#begin('~/.vim/plugged')

" python-mode python IDE features
" https://github.com/python-mode/python-mode
" Plug 'python-mode/python-mode', { 'for': 'python', 'branch': 'develop' }
" Use vim-plug to install rust syntax
" https://github.com/rust-lang/rust.vim
Plug 'rust-lang/rust.vim'
" Markdown stuff
" https://github.com/preservim/vim-markdown
Plug 'godlygeek/tabular'
Plug 'preservim/vim-markdown'
" https://github.com/neoclide/coc.nvim
" smart code completion, build from source
"Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'yarn install --frozen-lockfile'}
" non source
"Plug 'neoclide/coc.nvim', {'branch': 'release'}
" File explorer
" https://github.com/preservim/nerdtree
Plug 'preservim/nerdtree'
" Better status line
" https://github.com/vim-airline/vim-airline
Plug 'vim-airline/vim-airline'
" Linter/fixer
" https://github.com/dense-analysis/ale
" be sure to install the following packages:
" pylint,
Plug 'dense-analysis/ale'

call plug#end()

" Set folding to autodetect python indents
set foldmethod=indent
" Open all folds by default
set foldlevel=99
"autocmd BufEnter .vimprojects let PreFoldPosition = getpos('.') | silent! %foldopen! | call setpos('.', PreFoldPosition)

" Remove python-mode column
"let g:pymode_options_colorcolumn = 0

"autocmd StdinReadPre * let s:std_in=1
" Start NERDTree if no args are passsed to vim
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" comlete ale with tab
inoremap <silent><expr> <Tab>
\ pumvisible() ? "\<C-n>" : "\<TAB>"

" Set the ALE linters
let g:ale_linters = {
\ 'python': ['jedils', 'pylinl', 'flake8'],
\}

" Set the ALE fixers
let g:ale_fixers = {
\ 'python': ['autoflake', 'isort', 'trim_whitespace'],
\}

" Let ALE use airline
let g:airline#extensions#ale#enabled = 1
" Don't print errors to the buffer
let g:ale_virtualtext_cursor = 0
" Disable line too long errors
let g:ale_python_flake8_options = "--ignore=E501,W391"

" Airline enable tabline
let g:airline#extensions#tabline#enabled = 1

" Enable dark mode
set background=dark

filetype plugin indent on

syntax enable

set number relativenumber
set linebreak
set showbreak=+++
set showmatch
set visualbell

set hlsearch
set smartcase
set ignorecase
set incsearch

set autoindent
set shiftwidth=4
set smartindent
set smarttab
set softtabstop=4

set undolevels=1000
set backspace=indent,eol,start

set statusline+=%#warningmsg#
set statusline+=%*
