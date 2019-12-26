if exists('g:loaded_ctrlp_godoc') && g:loaded_ctrlp_godoc
  finish
endif
let g:loaded_ctrlp_godoc = 1

let s:godoc_var = {
\  'init':   'ctrlp#godoc#init()',
\  'accept': 'ctrlp#godoc#accept',
\  'lname':  'godoc',
\  'sname':  'gd',
\  'type':   'line',
\  'enter':  'ctrlp#godoc#enter()',
\  'exit':   'ctrlp#godoc#exit()',
\  'sort':   0,
\}

if exists('g:ctrlp_ext_vars') && !empty(g:ctrlp_ext_vars)
  let g:ctrlp_ext_vars = add(g:ctrlp_ext_vars, s:godoc_var)
else
  let g:ctrlp_ext_vars = [s:godoc_var]
endif


function! ctrlp#godoc#init()
  return s:list
endfunc

function! ctrlp#godoc#accept(mode, str)
  call ctrlp#exit()
  execute 'GoDoc '.a:str
endfunction

let s:list = []
function! ctrlp#godoc#enter()
  if len(s:list) == 0
    let s:list = systemlist('go list ...')
  endif
endfunction

function! ctrlp#godoc#exit()
  " do nothing
endfunction

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
function! ctrlp#godoc#id()
  return s:id
endfunction

" vim:fen:fdl=0:ts=2:sw=2:sts=2
