augroup filetypedetect
  au BufRead,BufNewFile *.html  setfiletype html
  au BufRead,BufNewFile *.js    setfiletype javascript
  au BufRead,BufNewFile *.ts    setfiletype typescript
augroup END
