(setq custom-file "~/.emacs.custom.el")
(package-initialize)

(add-to-list 'load-path "~/.emacs.local/")

;; Load basic helpers
(load "~/.emacs.rc/rc.el")

;; Modular config
(load "~/.emacs.rc/appearance-rc.el")
(load "~/.emacs.rc/completion-rc.el")
(load "~/.emacs.rc/editing-rc.el")
(load "~/.emacs.rc/programming-rc.el")
(load "~/.emacs.rc/simpc-rc.el")

;; Specific components
(load "~/.emacs.rc/misc-rc.el")
(load "~/.emacs.rc/org-mode-rc.el")
(load "~/.emacs.rc/autocommit-rc.el")

;;; Custom Hooks/Keys not in RC files yet
(add-hook 'emacs-lisp-mode-hook
          '(lambda ()
             (local-set-key (kbd "C-c C-j")
                            (quote eval-print-last-sexp))))
(add-to-list 'auto-mode-alist '("Cask" . emacs-lisp-mode))

(load "~/.emacs.shadow/shadow-rc.el" t)

(global-set-key (kbd "C-c c")   'compile)
(global-set-key (kbd "C-c C-w") 'count-words)

(load-file custom-file)

;; Disable backup files like file~
(setq make-backup-files nil)
(setq shell-file-name "/usr/bin/bash")
(put 'dired-find-alternate-file 'disabled nil)
