" Enable line numbers
set number

" Enable relative line numbers (optional)
set relativenumber

" Remap Ctrl+Backspace to delete word left
nnoremap <C-BS> dB
inoremap <C-BS> <C-W>

" Remap Ctrl+Delete to delete word right
nnoremap <C-Delete> dW
inoremap <C-Delete> <C-W>

" Ensure Ctrl+Backspace and Ctrl+Delete work in terminal
if has('nvim')
  " For Neovim, we need to handle terminal keycodes
  tnoremap <C-BS> <C-\><C-N>dB
  tnoremap <C-Delete> <C-\><C-N>dW
endif
