;;; Programming language configurations

;; C and Python use built-in tree-sitter modes
(setq-default c-basic-offset 4
              c-default-style '((java-mode . "java")
                                (awk-mode . "awk")
                                (other . "bsd")))

(add-hook 'c-mode-hook (lambda () (c-toggle-comment-style -1)))
(add-hook 'c-ts-mode-hook (lambda () (c-toggle-comment-style -1)))

;; LSP for C and Python (built-in Eglot)
(use-package eglot
  :hook ((c-mode c-ts-mode c++-mode c++-ts-mode simpc-mode python-mode python-ts-mode) . eglot-ensure)
  :config
  (setq eldoc-echo-area-prefer-doc-buffer-p t))

;; Yasnippet
(use-package yasnippet
  :config
  (setq yas/triggers-in-field nil
        yas-snippet-dirs '("~/.emacs.snippets/"))
  (yas-global-mode 1))

;; Magit
(use-package magit
  :bind (("C-c m s" . magit-status)
         ("C-c m l" . magit-log))
  :config
  (setq magit-auto-revert-mode nil
        magit-status-show-untracked-files 'all
        magit-process-popup-time 10))

;; Git Gutter
(use-package git-gutter
  :demand t
  :config
  (global-git-gutter-mode t)
  :bind (("C-c v n" . git-gutter:next-hunk)
         ("C-c v p" . git-gutter:previous-hunk)))

;; Eldoc for Elisp
(add-hook 'emacs-lisp-mode-hook 'eldoc-mode)

;; hl-todo
(use-package hl-todo
  :config
  (global-hl-todo-mode)
  (setq hl-todo-keyword-faces
        '(("TODO"    . "#fe8019")
          ("WARNING" . "#fabd2f")
          ("FIX"     . "#fb4934")
          ("NOTE"    . "#8bd5ca"))))

;; Haskell
(use-package haskell-mode
  :mode "\\.hs\\'"
  :config
  (setq haskell-process-type 'cabal-new-repl
        haskell-process-log nil))

;; TypeScript / Tide
(use-package tide
  :mode ("\\.ts\\'" "\\.tsx\\'" "\\.mts\\'")
  :config
  (defun rc/setup-tide ()
    (tide-setup)
    (flycheck-mode 1))
  (add-hook 'typescript-mode-hook #'rc/setup-tide))

;; Markdown
(use-package markdown-mode
  :mode (("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)))

;; YAML
(use-package yaml-mode
  :mode "\\.ya?ml\\'")

;; TOML
(use-package toml-mode
  :mode "\\.toml\\'")

;; Dockerfile
(use-package dockerfile-mode
  :mode "Dockerfile\\'")

;; Other major modes (loaded on demand via use-package)
(use-package rust-mode :mode "\\.rs\\'")
(use-package go-mode :mode "\\.go\\'")
(use-package lua-mode :mode "\\.lua\\'")
(use-package scala-mode :mode "\\.scala\\'")
(use-package clojure-mode :mode "\\.clj\\'")
(use-package kotlin-mode :mode "\\.kt\\'")
(use-package php-mode :mode "\\.php\\'")
(use-package racket-mode :mode "\\.rkt\\'")
(use-package nix-mode :mode "\\.nix\\'")
(use-package cmake-mode :mode "CMakeLists\\.txt\\'")
(use-package glsl-mode :mode "\\.glsl\\'")
(use-package graphviz-dot-mode :mode "\\.dot\\'")
(use-package nim-mode :mode "\\.nim\\'")
(use-package jinja2-mode :mode "\\.j2\\'")

;; HTML via nxml-mode (built-in)
(add-to-list 'auto-mode-alist '("\\.html\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.xsd\\'" . nxml-mode))

;; Assembly
(add-to-list 'auto-mode-alist '("\\.asm\\'" . asm-mode))

;; Compilation — smart default per file type
(require 'compile)
(add-to-list 'compilation-error-regexp-alist
             '("\\([a-zA-Z0-9\\.]+\\)(\\([0-9]+\\)\\(,\\([0-9]+\\)\\)?) \\(Warning:\\)?"
               1 2 (4) (5)))

(defun rc/smart-compile ()
  (interactive)
  (let* ((f (buffer-file-name))
         (default
           (cond ((derived-mode-p 'c-mode 'c-ts-mode)
                  (format "gcc -Wall -Wextra -o %s %s && ./%s"
                          (file-name-base f) (file-name-sans-extension f)
                          (file-name-base f)))
                 ((derived-mode-p 'c++-mode 'c++-ts-mode)
                  (format "g++ -Wall -Wextra -o %s %s && ./%s"
                          (file-name-base f) (file-name-sans-extension f)
                          (file-name-base f)))
                 ((derived-mode-p 'python-mode 'python-ts-mode)
                  (format "python3 %s" f))
                 ((derived-mode-p 'emacs-lisp-mode)
                  (format "emacs --batch --eval '(byte-compile-file \"%s\")'" f))
                 (t (if f f "make"))))
         (cmd (read-shell-command "Run: " default)))
    (let ((default-directory (if f (file-name-directory f) default-directory)))
      (async-shell-command cmd "*run*"))
    (with-current-buffer "*run*"
      (compilation-shell-minor-mode 1))))

(define-key global-map (kbd "C-c k")
  (lambda () (interactive)
    (let ((buf (get-buffer "*run*")))
      (when (and buf (get-buffer-process buf))
        (delete-process (get-buffer-process buf))))))

(provide 'programming-rc)
