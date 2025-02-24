# bashrcs

This is a collection of my personal `.bashrc` files. I was previously using github gists, but gists' source control only shows diffs, not the whole file, whereas you can use git to see whole past versions of a file.

## Usage

Clone this repo to your home directory, then add 
```bash
for file in ~/bashrcs/.bashrc.*; do source $file; done
```
to your `.bashrc` file. You can of course only source the files you want.

Note `xargs` doesn't work, because 'source' is a bash builtin, not an external command.