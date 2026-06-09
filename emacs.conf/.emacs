(setq custom-file "~/.emacs.custom.el")

(add-to-list 'load-path "~/.emacs.local/")

;; Modular config
(load "~/.emacs.rc/rc.el")
(load "~/.emacs.rc/appearance-rc.el")
(load "~/.emacs.rc/completion-rc.el")
(load "~/.emacs.rc/editing-rc.el")
(load "~/.emacs.rc/programming-rc.el")
(load "~/.emacs.rc/simpc-rc.el")
(load "~/.emacs.rc/media-rc.el")
(load "~/.emacs.rc/pdf-rc.el")
(load "~/.emacs.rc/misc-rc.el")
(load "~/.emacs.rc/org-mode-rc.el")
(load "~/.emacs.rc/autocommit-rc.el")

(load "~/.emacs.shadow/shadow-rc.el" t)

(global-set-key (kbd "C-c c")   'rc/smart-compile)
(global-set-key (kbd "C-x c")   'compile)
(global-set-key (kbd "C-x k")   'kill-compilation)
(global-set-key (kbd "C-k")     'kill-buffer)
(global-set-key (kbd "C-c C-w") 'count-words)

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c C-j") 'eval-print-last-sexp)))
(add-to-list 'auto-mode-alist '("Cask" . emacs-lisp-mode))

(load-file custom-file)

(setq shell-file-name "/usr/bin/bash")
(put 'dired-find-alternate-file 'disabled nil)
