" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')
" git diff
" use [c c] jump change hook
Plug 'airblade/vim-gitgutter'
" vim style theme tool
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" tree folder
Plug 'scrooloose/nerdtree'
Plug 'jiangmiao/auto-pairs'
Plug 'scrooloose/syntastic'
Plug 'stephpy/vim-yaml'
" search tool
" Plug 'kien/ctrlp.vim'
call plug#end()


"package setting-start

"vim-gitgutter to check git diff time
set updatetime=100

"vim-airline
let g:airline#extensions#tabline#enabled = 1
" tab 顯示的檔案路徑
let g:airline#extensions#tabline#formatter = 'unique_tail'


"auto-pairs
let g:AutoPairsFlyMode = 1

"package setting-end

"停止相容vi
set nocompatible

"show ruler words num
set ruler

"括號批配

set showmatch

"display line number
set number

"avoid backspace can't delete indent,eol,start
"ref: https://www.smslit.top/2016/11/27/vim-backspace-invalid/
"like set backspace=indent,eol,star
set backspace=2

"as:sc
set showcmd

"command history limit
set history=2000

"key pattern search in now
"as: is
set incsearch

"highlight search reuslt
"as: hls
set hlsearch

"search ignorecase
"as:ic
set ignorecase

"search for smart
"like search cat find Cat cAt caT
"with iignorecase enable search Cat only find Cat
"ref:https://magiclen.org/vimrc/
set smartcase

"replace tab to tab
"ref:https://blog.wu-boy.com/2010/08/vim-%E5%B0%87-tab-%E8%BD%89%E6%8F%9B%E6%88%90-space/
set expandtab

"auto indent
"as:ai
"ref:http://www.study-area.org/tips/vim/Vim-9.html
set autoindent

"fold setting
"delete
"ref:http://yyq123.blogspot.com/2011/09/vim-fold.html
set foldmethod=indent
set foldlevel=5
nnoremap <space> za <CR>

"support 256 color
set t_Co=256
"colorscheme gruvbox
"font color theme
color desert

"行首 tab highlight
highlight LeaderTab guifg=#666666
match LeaderTab /^\t/

"字數過長 highlight
highlight OverLength ctermbg=DarkGray ctermfg=white guibg=#592929
match OverLength /\%81v.\+/

"php syntastic
let g:syntastic_php_checkers = ['php', 'phpcs', 'phpmd']

" 特定檔案讀入轉換
au BufNewFile,BufRead *.py
	\ set tabstop=4 |
	\ set softtabstop=4 |
	\ set shiftwidth=4 |
	\ set textwidth=79 |
	\ set fileformat=unix |

au BufNewFile,BufRead *.php,*.json,*.vue,*.js,*.html,*.css,*.scss
	\ set tabstop=4 |
	\ set softtabstop=4 |
	\ set shiftwidth=4 |
	\ set textwidth=119 |


" add yaml stuffs
au BufNewFile,BufRead *.{yaml,yml}
       \ set filetype=yaml |
       \ set foldmethod=indent |
       \ set ts=2 |
       \ set sw=2 |
       \ set expandtab |

"notice reason
"ref:https://stackoverflow.com/a/49218216
syntax on
filetype indent on


function! RemoveTrailingWhitespace()
        if &ft != "diff"
                let b:curcol = col(".")
                let b:curline = line(".")
                silent! %s/\s\+$
                silent! %s/\(\s*\n\)\+\%$
                call cursor(b:curline, b:curcol)
        endif
endfunction

autocmd BufWritePre * call RemoveTrailingWhitespace()
