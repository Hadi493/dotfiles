;;; Programming language configurations (except simpc-mode)

;;; C-mode
(setq-default c-basic-offset 4
              c-default-style '((java-mode . "java")
                                (awk-mode . "awk")
                                (other . "bsd")))

(add-hook 'c-mode-hook (lambda ()
                         (interactive)
                         (c-toggle-comment-style -1)))

;;; LSP — real code intelligence via clangd (like nvim/zed)
;;; eglot is built-in since Emacs 29; completion routes through company-capf.
(require 'eglot)
(defun rc/eglot-ensure ()
  (eglot-ensure))
(add-hook 'c-mode-hook   #'rc/eglot-ensure)
(add-hook 'c++-mode-hook #'rc/eglot-ensure)
(add-hook 'rust-mode-hook #'rc/eglot-ensure)

(global-set-key (kbd "C-c l r") 'eglot-reconnect)
(global-set-key (kbd "C-c l s") 'eglot-shutdown)
(global-set-key (kbd "C-c l f") 'flymake-show-diagnostics-buffer)

;;; Haskell
(rc/require 'haskell-mode)
(setq haskell-process-type 'cabal-new-repl)
(setq haskell-process-log t)
(add-hook 'haskell-mode-hook 'haskell-indent-mode)
(add-hook 'haskell-mode-hook 'interactive-haskell-mode)
(add-hook 'haskell-mode-hook 'haskell-doc-mode)

;;; Typescript & Tide
(rc/require 'typescript-mode 'tide)
(add-to-list 'auto-mode-alist '("\\.mts\\'" . typescript-mode))

(defun rc/turn-on-tide-and-flycheck ()
  (interactive)
  (tide-setup)
  (flycheck-mode 1))

(add-hook 'typescript-mode-hook 'rc/turn-on-tide-and-flycheck)

;;; Yasnippet
(rc/require 'yasnippet)
(require 'yasnippet)
(setq yas/triggers-in-field nil)
(setq yas-snippet-dirs '("~/.emacs.snippets/"))
(yas-global-mode 1)

;;; Git Gutter
(rc/require 'git-gutter)
(require 'git-gutter)
(global-git-gutter-mode t)

(global-set-key (kbd "C-c v n") 'git-gutter:next-hunk)
(global-set-key (kbd "C-c v p") 'git-gutter:previous-hunk)

;;; Magit
(rc/require 'cl-lib 'magit)
(setq magit-auto-revert-mode nil
      magit-status-show-untracked-files 'all) ; Always show all untracked files
(global-set-key (kbd "C-c m s") 'magit-status)
(global-set-key (kbd "C-c m l") 'magit-log)

;;; Eldoc
(defun rc/turn-on-eldoc-mode ()
  (interactive)
  (eldoc-mode 1))

(add-hook 'emacs-lisp-mode-hook 'rc/turn-on-eldoc-mode)

;;; Compilation
(require 'compile)
(add-to-list 'compilation-error-regexp-alist
             '("\\([a-zA-Z0-9\\.]+\\)(\\([0-9]+\\)\\(,\\([0-9]+\\)\\)?) \\(Warning:\\)?"
               1 2 (4) (5)))

(defun compile-emacs-config ()
  "Compile the .emacs file."
  (interactive)
  (compile (format "emacs --batch --eval '(byte-compile-file \"%s\")'"
                   (expand-file-name "~/.emacs"))))

;;; Other modes
(rc/require 'uxntal-mode 'powershell 'proof-general)

(require 'basm-mode nil t)
(require 'fasm-mode nil t)
(require 'asm-mode nil t)
(add-to-list 'auto-mode-alist '("\\.asm\\'" . asm-mode))
(require 'porth-mode nil t)
(require 'noq-mode nil t)
(require 'jai-mode nil t)
(require 'umka-mode nil t)
(require 'c3-mode nil t)

(add-to-list 'auto-mode-alist '("\\.html\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.xsd\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.ant\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.ps1\\'" . powershell-mode))
(add-to-list 'auto-mode-alist '("\\.psm1\\'" . powershell-mode))
(add-to-list 'auto-mode-alist '("\\.ebi\\'" . lisp-mode))

;;; Batch require for modes that don't need extra config
(rc/require
 'scala-mode 'd-mode 'yaml-mode 'glsl-mode 'tuareg 'lua-mode
 'less-css-mode 'graphviz-dot-mode 'clojure-mode 'cmake-mode
 'rust-mode 'csharp-mode 'nim-mode 'jinja2-mode 'markdown-mode
 'purescript-mode 'nix-mode 'dockerfile-mode 'toml-mode 'nginx-mode
 'kotlin-mode 'go-mode 'php-mode 'racket-mode 'qml-mode 'ag 'elpy
 'rfc-mode 'sml-mode 'asm-mode)

(use-package hl-todo
  :ensure t
  :init
  (global-hl-todo-mode)
  :config
  (setq hl-todo-keyword-faces
        '(("TODO"    . "#fe8019")
          ("WARNING" . "#fabd2f")
          ("FIX"     . "#fb4934")
          ("NOTE"    . "#8bd5ca"))))

(provide 'programming-rc)
