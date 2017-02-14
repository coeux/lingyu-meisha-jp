set nocompatible
syntax on
filetype on
filetype plugin on
colorscheme desert
set nu
set ts=4
set softtabstop=4
set shiftwidth=4
set smarttab
set expandtab
set smartindent
set hls

set t_Co=256
set background=dark

set vb t_vb=

execute "cd" substitute(expand("%:h"),' ','\\ ','g')
 
hi clear

if exists("syntax_on")
syntax reset
endif

let colors_name = "wombat"

if version >= 700
    hi CursorLine guibg=#2d2d2d ctermbg=236 cterm=none
    hi CursorColumn guibg=#2d2d2d ctermbg=236 cterm=none
    hi MatchParen guifg=#f6f3e8 guibg=#857b6f gui=bold ctermfg=230 ctermbg=101 cterm=bold
    hi Pmenu      guifg=#f6f3e8 guibg=#444444 ctermfg=230 ctermbg=238 cterm=none
    hi PmenuSel   guifg=#000000 guibg=#cae682 ctermfg=16 ctermbg=150 cterm=none
endif

hi Search       term=reverse ctermbg=11 guibg=Blue
hi Cursor       guifg=NONE    guibg=#656565 gui=none ctermfg=230 ctermbg=241 cterm=none
hi Normal       guifg=#f6f3e8 guibg=#242424 gui=none ctermfg=230 ctermbg=235 cterm=none
hi NonText      guifg=#808080 guibg=#303030 gui=none ctermfg=244 ctermbg=236 cterm=none
hi LineNr       guifg=#857b6f guibg=#000000 gui=none ctermfg=101 ctermbg=16 cterm=none
hi StatusLine   guifg=#f6f3e8 guibg=#444444 gui=italic ctermfg=230 ctermbg=238 cterm=NONE
hi StatusLineNC guifg=#857b6f guibg=#444444 gui=none ctermfg=101 ctermbg=238 cterm=none
hi VertSplit    guifg=#444444 guibg=#444444 gui=none ctermfg=238 ctermbg=238 cterm=none
hi Folded       guibg=#384048 guifg=#a0a8b0 gui=none ctermfg=103 ctermbg=60 cterm=none
hi Title        guifg=#f6f3e8 guibg=NONE    gui=bold ctermfg=230 ctermbg=235 cterm=bold
hi Visual       guifg=#f6f3e8 guibg=#444444 gui=none ctermfg=230 ctermbg=238 cterm=none
hi SpecialKey   guifg=#808080 guibg=#343434 gui=none ctermfg=244 ctermbg=236 cterm=none

hi Comment      guifg=#99968b gui=italic ctermfg=246 ctermbg=235 cterm=NONE
hi Todo         guifg=#8f8f8f gui=italic ctermfg=245 ctermbg=235 cterm=NONE
hi Constant     guifg=#e5786d gui=none ctermfg=167 ctermbg=235 cterm=none
hi String       guifg=#95e454 gui=italic ctermfg=113 ctermbg=235 cterm=NONE
hi Identifier   guifg=#cae682 gui=none ctermfg=150 ctermbg=235 cterm=none
hi Function     guifg=#cae682 gui=none ctermfg=150 ctermbg=235 cterm=none
hi Type         guifg=#cae682 gui=none ctermfg=150 ctermbg=235 cterm=none
hi Statement    guifg=#8ac6f2 gui=none ctermfg=117 ctermbg=235 cterm=none
hi Keyword      guifg=#8ac6f2 gui=none ctermfg=117 ctermbg=235 cterm=none
hi PreProc      guifg=#e5786d gui=none ctermfg=167 ctermbg=235 cterm=none
hi Number       guifg=#e5786d gui=none ctermfg=167 ctermbg=235 cterm=none
hi Special      guifg=#e7f6da gui=none ctermfg=194 ctermbg=235 cterm=none
