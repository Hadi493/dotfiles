set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,gbk,gb2312,cp936
set termencoding=utf-8
syntax on
filetype plugin indent on
" set background=dark
colorscheme murphy
" colorscheme slate
" colorscheme wildcharm
set number
set relativenumber
set cursorline
set showcmd
set ruler
set wildmenu
set lazyredraw
set ttyfast
set clipboard=unnamedplus
set mouse=a
set splitbelow
set splitright
set ignorecase
set smartcase
set incsearch
set hlsearch
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set backspace=indent,eol,start
set scrolloff=5
set sidescrolloff=5
set wrap
set linebreak
set nolist
set showmatch
set matchtime=2
set updatetime=300
set timeoutlen=500
set shortmess+=c
set signcolumn=yes
set foldmethod=indent
set foldlevel=99
set undofile

" Open a new terminal
nnoremap t :terminal<CR>

" Open a new tab vertically
nnoremap T :vsplit<CR>

" toggle buffer open buffer
nnoremap <Tab> :bnext<CR>

" toggle buffer to terminal to buffer
nnoremap <S-L> :bprevious<CR>

" Open file explorer
nnoremap ff :Texplore<CR>

" save current file
nnoremap <C-s> :w<CR>

" save all and exit
nnoremap <C-x> :wqa<CR>

" quit vim
nnoremap <C-q> :q<CR>
