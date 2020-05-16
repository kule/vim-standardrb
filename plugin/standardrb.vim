let s:error = 0

function! Standardrb(args)
  if &filetype == "ruby"
    call s:RunStandardrb(@%, 1, a:args)
  else
    echo "Cannot run standardrb on non-ruby file"
  endif
endfunction

function! StandardrbFix()
  if &filetype == "ruby"
    call s:RunStandardrb(@%, 0, "--auto-correct --safe")
  else
    echo "Cannot run standardrb on non-ruby file"
  endif
endfunction

function! StandardrbAll(args)
  call s:RunStandardrb("", 1, a:args)
endfunction

function! s:RunStandardrb(path, async, args)
  let l:standardrb_args = a:args . join(a:000, " ")

  if !empty(a:path)
    let l:standardrb_args = l:standardrb_args . " " . a:path
  endif

  let l:standardrb_command = s:StandardrbCmd(). " " . l:standardrb_args

  if s:error
    return
  endif

  if a:async
    call s:executeCmdAsync(l:standardrb_command)
  else
    call s:executeCmd(l:standardrb_command)
  endif
endfunction

function! s:StandardrbCmd()
  if exists('g:standardrb_cmd')
    if g:standardrb_cmd =~ "emacs"
      let l:standardrb_command = g:standardrb_cmd
    else
      let l:standardrb_command = g:standardrb_cmd . " --format emacs"
    endif
  else
    if !executable('standardrb')
      let s:error = 1
      echom s:error
      echoerr "Standardrb: standardrb binary not found. Please install it first"
      return
    endif

    let l:standardrb_command = 'standardrb --format emacs'
    let l:root = getcwd()
    let l:gemfile_path = root . "/Gemfile"
    if filereadable(l:gemfile_path)
      let l:body = join(readfile(l:gemfile_path), "\n")
      let l:bundle_path = matchstr(l:body, "standard")
      if empty(l:bundle_path)
        let l:standardrb_command = 'standardrb --format emacs'
      else
        let l:standardrb_command = 'bundle exec standardrb --format emacs'
      endif
    endif
  endif

  return l:standardrb_command
endfunction

function! BackgroundCmdFinish(...)
  echom "Complete"
  execute "cfile! " . g:backgroundCommandOutput

  let l:match_count = len(getqflist())

  if l:match_count
    copen
  else
    cclose
    echom "No errors! bravo!"
  endif

  unlet g:backgroundCommandOutput
endfunction

function! s:executeCmdAsync(cmd)
  echom "Running Standardrb"

  let g:backgroundCommandOutput = tempname()
  if has('nvim')
    call jobstart(a:cmd . ' > ' . g:backgroundCommandOutput, {'on_exit': 'BackgroundCmdFinish'})
  else
    call job_start(a:cmd, {'close_cb': 'BackgroundCmdFinish', 'out_io': 'file', 'out_name': g:backgroundCommandOutput})
  endif
endfunction

function! s:executeCmd(cmd)
  echom a:cmd
  let oldautoread=&autoread
  set autoread
  silent !clear
  execute "!" . a:cmd
  redraw
  let &autoread=oldautoread
endfunction

command! -nargs=* Standardrb call Standardrb(<q-args>)
command! -nargs=* StandardrbAll call StandardrbAll(<q-args>)
command! -nargs=0 StandardrbFix call StandardrbFix()
