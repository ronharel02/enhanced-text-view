# Enhanced Text View

A small extension that renders ANSI SGR escape codes when viewing .txt files in your browser.

Based on [ansi-to-html](https://github.com/rburns/ansi-to-html).

## Build Dependencies

The icon generation target in `Makefile` uses `sponge` (from GNU `moreutils`), `jq` and `imagemagick`, and the packaging is done in a `docker` container.

## TODO

- [ ] Add options page.
  - [ ] Toggle line numbers.
  - [ ] Custom RGB colors.
- [ ] Add hyperlink support.
