To compile, edit the source file as desired, then run `make` to compile, or `# make install` to install it. PKGBUILD supplied for Arch users, though don't forget to edit the source to fit your needs.

If you don't use dwm or some other WM where the statusline is read from `xsetroot -name` you'll have to reimplement that function yourself.

Usage:
Add `status-string-maker &` to your xinitrc. That's about it!
