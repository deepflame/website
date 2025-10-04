---
title: Easily format JSON in Vim
date: 2015-11-25 09:33 UTC
tags: vim, json, tooling
---

Nowadays we work a lot with JSON data. I had an API documentation with a lot of JSON samples. However the samples were all unformatted. So I tried to find an easy way to format them inside Vim.

READMORE

There are [some][1] [blog][2] [posts][3] out there alread with this trick. But I like to write about things again to keep them in my repository and to remember them better.

## Formatting a JSON file

If you have a JSON file you can use Python's json.tool to format the whole document like this:

```vim
:%!python -m json.tool
```

type this in normal mode in vim. The `:` will let you enter a vim command, `%` will select the current file, `!` will execute the following command on the shell.
The nice thing is that the current buffer will be overwritten by the results of the shell command. In this case the formatted JSON document.

## Formatting JSON inside a text file

But what if we do not have a whole JSON file but e.g. a Markdown file with some JSON inside? Well, we can select the JSON lines in visual mode (&lt;shift&gt;+v) first.
When we press `:` now to enter a command it changes automatically to this:

```vim
:'<,'>
```

and we can enter the same command at the end like this:

```vim
:'<,'>!python -m json.tool
```

Et voilà! We have our JSON line(s) properly formatted.

This works with any range in Vim.

[1]: https://coderwall.com/p/faceag/format-json-in-vim
[2]: http://blog.realnitro.be/2010/12/20/format-json-in-vim-using-pythons-jsontool-module/
[3]: https://pascalprecht.github.io/2014/07/10/pretty-print-json-in-vim/
