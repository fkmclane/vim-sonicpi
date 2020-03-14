if exists('g:loaded_sonicpi')
  finish
endif
let g:loaded_sonicpi = 1

if !exists('g:sonicpi_command')
  let g:sonicpi_command = 'sonic-pi-tool'
endif

if !exists('g:sonicpi_check')
  let g:sonicpi_check = 'check'
endif

if !exists('g:sonicpi_send')
  let g:sonicpi_send = 'eval-stdin'
endif

if !exists('g:sonicpi_logs')
  let g:sonicpi_logs = 'logs'
endif

if !exists('g:sonicpi_record')
  let g:sonicpi_record = 'record'
endif

if !exists('g:sonicpi_stop')
  let g:sonicpi_stop = 'stop'
endif

if !exists('g:vim_redraw')
  let g:vim_redraw = 0
endif

if !exists('g:sonicpi_enabled')
  let g:sonicpi_enabled = 1
endif

if !exists('g:sonicpi_keymaps_enabled')
  let g:sonicpi_keymaps_enabled = 1
endif

let s:record_job = v:null

" Contextual initialization modelled after tpope's vim-sonicpi
function! sonicpi#detect()
  " Test if Sonic Pi is available.
  silent! execute '! ' . g:sonicpi_command . ' ' . g:sonicpi_check . ' 2>&1 >/dev/null'
  if v:shell_error == 0 && expand(&filetype) == 'ruby' && g:sonicpi_enabled
    if g:sonicpi_keymaps_enabled
      call s:load_keymaps()
    endif
    call s:load_autocomplete()
    call s:load_syntax()
  endif
endfunction

augroup sonicpi
  autocmd!
  autocmd BufNewFile,BufReadPost *.rb call sonicpi#detect()
  autocmd FileType               ruby call sonicpi#detect()
  autocmd ExitPre                * call s:SonicPiExit()
  " Not entirely sure this one will be helpful...
  autocmd VimEnter               * if expand('<amatch>') == '\v*.rb' | endif
augroup END

" Autocomplete functionality calls Ruby if no sonicpi directives found
function! s:load_autocomplete()
  if exists('&ofu')
    setlocal omnifunc=sonicpicomplete#Complete
    " Enable words from buffer to be autocompleted unless otherwise set
    if !exists('g:rubycomplete_buffer_loading')
      let g:rubycomplete_buffer_loading = 1
    endif
  endif
endfunction

" Extend Ruby syntax to include Sonic Pi terms
function! s:load_syntax()
  runtime! syntax/sonicpi.vim
endfunction

function! s:SonicPiSendBuffer()
  silent! execute 'w ! ' . g:sonicpi_command . ' ' . g:sonicpi_send . ' 2>&1 >/dev/null'
endfunction

function! s:SonicPiShowLog()
  if g:sonicpi_logs == ''
    echo "No logs subcommand defined for '" . g:sonicpi_command . "'"
    return
  endif

  if !has('nvim') && !has('terminal')
    echo "Command ':terminal' not available"
    return
  endif

  let cur = winnr()

  if bufwinnr('Sonic Pi Log') > 0
    execute bufwinnr('Sonic Pi Log') . ' wincmd w'
    normal G0
    execute cur . ' wincmd w'
    return
  endif

  if buflisted('Sonic Pi Log')
    execute 'belowright vertical 70 split #' . bufnr('Sonic Pi Log')
    normal G0
    execute cur . ' wincmd w'
    return
  endif

  belowright vertical 70 new
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap

  setlocal nomodifiable
  setlocal nomodified
  setlocal nonumber

  silent! file Sonic Pi Log

  if has('nvim')
    let term = 'terminal'
  else
    let term = 'terminal ++curwin'
  endif

  execute term . ' ' . g:sonicpi_command . ' ' . g:sonicpi_logs

  setlocal nonumber

  silent! file Sonic Pi Log

  normal G0

  execute cur . ' wincmd w'
endfunction

function! s:SonicPiCloseLog()
  if bufwinnr('Sonic Pi Log') > 0
    execute bufwinnr('Sonic Pi Log') . ' wincmd c'
  endif
  if len(win_findbuf(bufnr('Sonic Pi Log'))) <= 0
    execute bufnr('Sonic Pi Log') . ' bdelete!'
  endif
endfunction

function! s:SonicPiCloseAll()
  if buflisted('Sonic Pi Log')
    execute bufnr('Sonic Pi Log') . ' bdelete!'
  endif
endfunction

function! s:SonicPiRecordExitHandler(job, data, ...)
  let s:record_job = v:null
endfunction

function! s:SonicPiRecord(fname)
  if g:sonicpi_record == ''
    echo "No record subcommand defined for '" . g:sonicpi_command . "'"
    return
  endif

  if !has('nvim') && !(has('job') && has('channel'))
    echo 'Job control not available'
    return
  endif

  if s:record_job != v:null
    echo 'A recording session is already running'
    return
  endif

  let fname = fnamemodify(expand(a:fname), ':p')

  if has('nvim')
    let s:record_job = jobstart([g:sonicpi_command, g:sonicpi_record, fname], {'on_exit': function('s:SonicPiRecordExitHandler')})
    if s:record_job <= 0
      s:record_job = v:null
      echo 'Error starting recording session'
      return
    endif
  else
    let s:record_job = job_start([g:sonicpi_command, g:sonicpi_record, fname], {'exit_cb': function('s:SonicPiRecordExitHandler')})
    if job_status(s:record_job) != "run"
      s:record_job = v:null
      echo 'Error starting recording session'
      return
    endif
  endif
endfunction

function! s:SonicPiRecordStop()
  if !has('nvim') && !(has('job') && has('channel'))
    echo 'Job control not available'
    return
  endif

  if s:record_job == v:null
    echo 'There is no current recording session'
    return
  endif

  if has('nvim')
    call chansend(s:record_job, "\n")
  else
    let chan = job_getchannel(s:record_job)
    call ch_sendraw(job_getchannel(s:record_job), "\n")
  endif
endfunction

function! s:SonicPiStop()
  silent! execute '! ' . g:sonicpi_command . ' ' . g:sonicpi_stop . ' 2>&1 >/dev/null'
  if g:vim_redraw
    execute ':redraw!'
  endif
endfunction

function! s:SonicPiExit()
  call s:SonicPiCloseAll()
  if s:record_job != v:null
    call s:SonicPiRecordStop()
  endif
endfunction

" Export public API
command! -nargs=0 SonicPiSendBuffer call s:SonicPiSendBuffer()
command! -nargs=0 SonicPiShowLog call s:SonicPiShowLog()
command! -nargs=0 SonicPiCloseLog call s:SonicPiCloseLog()
command! -nargs=0 SonicPiCloseAll call s:SonicPiCloseAll()
command! -nargs=1 -complete=file SonicPiRecord call s:SonicPiRecord(<f-args>)
command! -nargs=0 SonicPiRecordStop call s:SonicPiRecordStop()
command! -nargs=0 SonicPiStop call s:SonicPiStop()

" Set keymaps in Normal mode
function! s:load_keymaps()
  if g:sonicpi_logs != '' && (has('nvim') || has('terminal'))
    nnoremap <leader>r :SonicPiShowLog<CR>:SonicPiSendBuffer<CR>
    nnoremap <leader>c :SonicPiCloseLog<CR>
  else
    nnoremap <leader>r :SonicPiSendBuffer<CR>
  endif
  nnoremap <leader>S :SonicPiStop<CR>
endfunction
