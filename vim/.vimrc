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
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'sheerun/vim-polyglot'
Plug 'editorconfig/editorconfig-vim'
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

"vim-go settings
let g:go_fmt_command = "goimports"    " 存檔時自動修正 import 並排版
let g:go_auto_type_info = 1           " 自動顯示變數類型
let g:go_highlight_functions = 1      " 高亮函式名稱
let g:go_highlight_methods = 1        " 高亮方法名稱
let g:go_highlight_operators = 1      " 高亮運算子
let g:go_highlight_types = 1          " 高亮類型名稱
let g:go_highlight_build_constraints = 1

"auto-pairs
let g:AutoPairsFlyMode = 1

"package setting-end


"show ruler words num
set ruler

"括號批配

set showmatch

"display line number
set number

"更現代的退格鍵行為
set backspace=indent,eol,start

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

"開啟插件與縮排支援
syntax on
filetype plugin indent on


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