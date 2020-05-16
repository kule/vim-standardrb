# Vim Standardrb

Vim & Neovim plugin to run [Standardrb](https://github.com/testdouble/standard)
and display the results in a quickfix window. Most of this is same as the
[Vim Rubocop](https://github.com/deepredsky/vim-rubocop) plugin.
Credit to deepredsky & mgmy.

## Usage

```
:Standardrb " Runs standard on the current buffer
:StandardrbAll " Runs standard on the whole project
:StandardrbAll --no-display-cop-names" Run standard with custom options
:StandardrbFix " Fix standard issues for current file. This will not be async.
```

By default it will look at Gemfile and use `bundle exec standardrb --format emacs`
if standard is specified in the Gemfile, otherwise it will fallback to using
`standardrb --format emacs`. This can be overridden

```
let g:standardrb_cmd = "bundle exec standardrb --no-display-cop-names"
```

NOTE that emacs formatter is required for this plugin to populate quickfix list

