;;; editing-rc.el --- General editing improvements -*- lexical-binding: t; -*-

;;; Multiple cursors
(rc/require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->")         'mc/mark-next-like-this)
(global-set-key (kbd "C-<")         'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<")     'mc/mark-all-like-this)
(global-set-key (kbd "C-\"")        'mc/skip-to-next-like-this)
(global-set-key (kbd "C-:")         'mc/skip-to-previous-like-this)

;;; Move Text
(rc/require 'move-text)
(global-set-key (kbd "M-p") 'move-text-up)
(global-set-key (kbd "M-n") 'move-text-down)
(global-set-key (kbd "M-<up>") 'move-text-up)
(global-set-key (kbd "M-<down>") 'move-text-down)

;;; Whitespace mode handling
(defun rc/set-up-whitespace-handling ()
  (interactive)
  (add-hook 'write-file-functions 'delete-trailing-whitespace nil t))

(let ((hooks '(tuareg-mode-hook
               c++-mode-hook
               c-mode-hook
               simpc-mode-hook
               emacs-lisp-mode-hook
               java-mode-hook
               lua-mode-hook
               rust-mode-hook
               scala-mode-hook
               markdown-mode-hook
               haskell-mode-hook
               python-mode-hook
               erlang-mode-hook
               asm-mode-hook
               fasm-mode-hook
               go-mode-hook
               nim-mode-hook
               yaml-mode-hook
               porth-mode-hook)))
  (dolist (hook hooks)
    (add-hook hook 'rc/set-up-whitespace-handling)))

;;; Word wrap
(defun rc/enable-word-wrap ()
  (interactive)
  (toggle-word-wrap 1))

(add-hook 'markdown-mode-hook 'rc/enable-word-wrap)

;; Save to disk on idle (modern style)
(setq auto-save-visited-interval 30)
(if (fboundp 'auto-save-visited-mode)
    (auto-save-visited-mode 1)
  (setq auto-save-default t))
;;
;; Notification in the echo area
(defun rc/show-save-status ()
  "Show a message for saves that are not manual `save-buffer' calls."
  (when (not (memq this-command '(save-buffer save-some-buffers)))
    (message "(Saved %s)" (buffer-name))))

(add-hook 'after-save-hook 'rc/show-save-status)


;; Prose and Grammar
;; Needs 'aspell' and 'LanguageTool' installed on the system
(rc/require 'writegood-mode 'langtool)
(add-hook 'text-mode-hook 'flyspell-mode)
(add-hook 'text-mode-hook 'writegood-mode)
(add-hook 'markdown-mode-hook 'flyspell-mode)
(add-hook 'markdown-mode-hook 'writegood-mode)

;; Try to find LanguageTool jar automatically
(let ((lt-path "/usr/share/java/languagetool/languagetool-commandline.jar"))
  (when (file-exists-p lt-path)
    (setq langtool-language-tool-jar lt-path)))

;;; Window resize
(global-set-key (kbd "C-S-<up>")    'enlarge-window)
(global-set-key (kbd "C-S-<down>")  'shrink-window)
(global-set-key (kbd "C-S-<left>")  'shrink-window-horizontally)
(global-set-key (kbd "C-S-<right>") 'enlarge-window-horizontally)

(provide 'editing-rc)
