augroup filetypedetect
  au BufRead,BufNewFile *.html  setfiletype html
  au BufRead,BufNewFile *.js    setfiletype javascript
  au BufRead,BufNewFile *.ts    setfiletype typescript
  au BufRead,BufNewFile *.cr    setfiletype crystal
augroup END
