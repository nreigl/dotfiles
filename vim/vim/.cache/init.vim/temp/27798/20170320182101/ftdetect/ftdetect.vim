if v:version < 704
  " NOTE: this line fixes an issue with the default system-wide lisp ftplugin
  "       which didn't define b:undo_ftplugin on older Vim versions
  "       (*.jl files are recognized as lisp)
  autocmd BufRead,BufNewFile *.jl    let b:undo_ftplugin = "setlocal comments< define< formatoptions< iskeyword< lisp<"
endif

autocmd BufRead,BufNewFile *.jl      set filetype=julia

autocmd BufEnter *                   call LaTeXtoUnicode#Refresh()
autocmd FileType *                   call LaTeXtoUnicode#Refresh()

autocmd VimEnter *                    call LaTeXtoUnicode#Init()

" This autocommand is used to postpone the first initialization of LaTeXtoUnicode as much as possible,
" by calling LaTeXtoUnicode#SetTab amd LaTeXtoUnicode#SetAutoSub only at InsertEnter or later
augroup L2UInit
  autocmd InsertEnter *                   let g:did_insert_enter = 1 | call LaTeXtoUnicode#Init(0)
augroup END
au BufNewFile,BufRead *.js setf javascript
au BufNewFile,BufRead *.jsm setf javascript
au BufNewFile,BufRead Jakefile setf javascript
au BufNewFile,BufRead *.es6 setf javascript

fun! s:SelectJavascript()
  if getline(1) =~# '^#!.*/bin/\%(env\s\+\)\?node\>'
    set ft=javascript
  endif
endfun
au BufNewFile,BufRead * call s:SelectJavascript()
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim ftdetect file
"
" Language: JSX (JavaScript)
" Maintainer: Max Wang <mxawng@gmail.com>
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Whether the .jsx extension is required.
if !exists('g:jsx_ext_required')
  let g:jsx_ext_required = 1
endif

" Whether the @jsx pragma is required.
if !exists('g:jsx_pragma_required')
  let g:jsx_pragma_required = 0
endif

if g:jsx_pragma_required
  " Look for the @jsx pragma.  It must be included in a docblock comment before
  " anything else in the file (except whitespace).
  let s:jsx_pragma_pattern = '\%^\_s*\/\*\*\%(\_.\%(\*\/\)\@!\)*@jsx\_.\{-}\*\/'
  let b:jsx_pragma_found = search(s:jsx_pragma_pattern, 'npw')
endif

" Whether to set the JSX filetype on *.js files.
fu! <SID>EnableJSX()
  if g:jsx_pragma_required && !b:jsx_pragma_found | return 0 | endif
  if g:jsx_ext_required && !exists('b:jsx_ext_found') | return 0 | endif
  return 1
endfu

autocmd BufNewFile,BufRead *.jsx let b:jsx_ext_found = 1
autocmd BufNewFile,BufRead *.jsx set filetype=javascript.jsx
autocmd BufNewFile,BufRead *.js
  \ if <SID>EnableJSX() | set filetype=javascript.jsx | endif
if has('nvim')
  aug set_repl_cmd
    au!
    " Ruby and Rails
    au FileType ruby,eruby
          \ if executable('bundle') && filereadable('config/application.rb') |
          \   call neoterm#repl#set('bundle exec rails console') |
          \ elseif executable(g:neoterm_repl_ruby) |
          \   call neoterm#repl#set(g:neoterm_repl_ruby) |
          \ end
    " Python
    au FileType python
          \ let s:argList = split(g:neoterm_repl_python) |
          \ if len(s:argList) > 0 && executable(s:argList[0]) |
          \   call neoterm#repl#set(g:neoterm_repl_python) |
          \ elseif executable('ipython') |
          \   call neoterm#repl#set('ipython --no-autoindent') |
          \ elseif executable('python') |
          \   call neoterm#repl#set('python') |
          \ end
    " JavaScript
    au FileType javascript
          \ if executable('node') |
          \   call neoterm#repl#set('node') |
          \ end
    " Elixir
    au FileType elixir
          \ if filereadable('config/config.exs') |
          \   call neoterm#repl#set('iex -S mix') |
          \ elseif &filetype == 'elixir' |
          \   call neoterm#repl#set('iex') |
          \ endif
    " Julia
    au FileType julia
          \ if executable('julia') |
          \   call neoterm#repl#set('julia') |
          \ end
    " PARI/GP
    au FileType gp
          \ if executable('gp') |
          \   call neoterm#repl#set('gp') |
          \ end
    " R
    au FileType r,rmd
          \ if executable('R') |
          \   call neoterm#repl#set('R') |
          \ end
    " Octave
    au FileType octave
          \ if executable('octave') |
          \   if executable('octave-cli') |
          \     if g:neoterm_repl_octave_qt |
          \       call neoterm#repl#set('octave --no-gui') |
          \     else |
          \       call neoterm#repl#set('octave-cli') |
          \     end |
          \   else |
          \     call neoterm#repl#set('octave') |
          \   end |
          \ end
    " MATLAB
    au FileType matlab
          \ if executable('matlab') |
          \   call neoterm#repl#set('matlab -nodesktop -nosplash') |
          \ end
    " Idris
    au FileType idris,lidris
          \ if executable('idris') |
          \   call neoterm#repl#set('idris') |
          \ end
    " Haskell
    au FileType haskell
          \ if executable('stack') |
          \ call neoterm#repl#set('stack ghci') |
          \ elseif executable('ghci') |
          \   call neoterm#repl#set('ghci') |
          \ end
    au FileType php
          \ let s:argList = split(g:neoterm_repl_php) |
          \ if len(s:argList) > 0 && executable(s:argList[0]) |
          \   call neoterm#repl#set(g:neoterm_repl_php) |
          \ elseif executable('psysh') |
          \   call neoterm#repl#set('psysh') |
          \ elseif executable('php') |
          \   call neoterm#repl#set('php -a') |
          \ end
    " Clojure
    au FileType clojure
          \ if executable('lein') |
          \   call neoterm#repl#set('lein repl') |
          \ end
  aug END
end
autocmd BufNewFile,BufRead *.Rout set ft=rout
autocmd BufNewFile,BufRead *.Rout.save set ft=rout
autocmd BufNewFile,BufRead *.Rout.fail set ft=rout
autocmd BufNewFile,BufRead *.ts setlocal filetype=typescript
autocmd BufNewFile,BufRead *.json setlocal filetype=json
autocmd BufNewFile,BufRead *.jsonp setlocal filetype=json
autocmd BufNewFile,BufRead *.geojson setlocal filetype=json
autocmd BufNewFile,BufRead *.ts,*.tsx setlocal filetype=typescript
" Detect syntax file.
autocmd BufNewFile,BufRead *.snip,*.snippets set filetype=neosnippet
autocmd BufNewFile,BufRead *.markdown,*.md,*.mdown,*.mkd,*.mkdn
      \ if &ft =~# '^\%(conf\|modula2\)$' |
      \   set ft=markdown |
      \ else |
      \   setf markdown |
      \ endif
au BufNewFile,BufRead .tern-project setf json
au BufNewFile,BufRead .tern-config setf json
autocmd BufNewFile,BufRead *.stan,*.STAN setfiletype stan
" Language:    CoffeeScript
" Maintainer:  Mick Koch <mick@kochm.co>
" URL:         http://github.com/kchmck/vim-coffee-script
" License:     WTFPL

autocmd BufNewFile,BufRead *.coffee set filetype=coffee
autocmd BufNewFile,BufRead *Cakefile set filetype=coffee
autocmd BufNewFile,BufRead *.coffeekup,*.ck set filetype=coffee
autocmd BufNewFile,BufRead *._coffee set filetype=coffee

function! s:DetectCoffee()
    if getline(1) =~ '^#!.*\<coffee\>'
        set filetype=coffee
    endif
endfunction

autocmd BufNewFile,BufRead * call s:DetectCoffee()
autocmd BufNewFile,BufRead {.,}tmux*.conf set ft=tmux | compiler tmux
