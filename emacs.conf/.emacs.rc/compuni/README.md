# Compuni

Compuni's an utility package for GNU Emacs 29+ that provides commands to help insert unicode. Compuni aims to replace the slow and ugly built-in `insert-char` and `emoji-search` with fast, in-buffer unicode completion. It uses [company](https://company-mode.github.io/) as an ephemeral *(non-persistent)* UI frontend for the in-buffer drop-down menu of options; it does not persist in `company-backends` nor does it require the user to keep `company-mode` enabled in the buffer.

Compuni provides two commands for inserting unicode:
* `compuni-insert-unicode`
* `compuni-insert-emoji`

Where the latter acts almost the exact same as the former, except it filters out non-emoji symbols from the options. These functions can be bound to your prefered combination of keys to easily and effortlessly insert unicode and emojis in the active buffer.

When one of these commands is used, it creates a cache of symbols and font heights to speed up subsequent calls. Thus, compuni also provides a `compuni-clear-cache` function to free up that space on-demand.

## Usage
Compuni isn't on any package repositories yet, so you gotta clone this repo and load it yourself.

Example configuration with `use-package`:
```elisp
(use-package compuni
  :ensure nil
  :load-path "/path/to/compuni"
  :after company
  :commands (compuni-insert-unicode compuni-insert-emoji)
  :bind (("C-c u u" . compuni-insert-unicode)
         ("C-c u e" . compuni-insert-emoji))
  :custom
  (compuni-max-candidates 50))
```


Compuni in action:

[https://github.com/user-attachments/assets/](https://github.com/user-attachments/assets/4bdfb2b1-e58a-459c-be42-6e9df9e99312)

## Customization
Compuni can be customized through these two variable:
* `compuni-max-candidates` : maximum number of candidates returned per query *(default: 50)*.
* `compuni-glyph-face` : face applied to glyphs in the left margin *(overrides `company-tooltip-annotation` foreground/style if customized)*.

## LLM usage
**DISCLAIMER:** This package was made with lots of AI assistance. The tests were almost entirely written by an LLM and the main file was written with lots of assistance as well. This README was completely written by me however, if you care.
