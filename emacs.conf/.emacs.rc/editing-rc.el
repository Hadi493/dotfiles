;;; General editing improvements

(use-package multiple-cursors
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->"         . mc/mark-next-like-this)
         ("C-<"         . mc/mark-previous-like-this)
         ("C-c C-<"     . mc/mark-all-like-this)
         ("C-\""        . mc/skip-to-next-like-this)
         ("C-:"         . mc/skip-to-previous-like-this)))

(use-package move-text
  :bind (("M-p" . move-text-up)
         ("M-n" . move-text-down)
         ("M-<up>" . move-text-up)
         ("M-<down>" . move-text-down)))

;; which-key: shows available keybindings as you type a prefix
(use-package which-key
  :config
  (which-key-mode 1))

;; avy: jump cursor to any visible character in 2-3 keystrokes
(use-package avy
  :bind (("C-c j" . avy-goto-char-timer)
         ("C-c C-j" . avy-goto-line)))

;; rainbow-delimiters: colorize nested parentheses by depth
(use-package rainbow-delimiters
  :commands rainbow-delimiters-mode
  :init
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
  :config
  (set-face-attribute 'rainbow-delimiters-depth-1-face nil :foreground "#FFB454")
  (set-face-attribute 'rainbow-delimiters-depth-2-face nil :foreground "#59C2FF")
  (set-face-attribute 'rainbow-delimiters-depth-3-face nil :foreground "#AAD94C")
  (set-face-attribute 'rainbow-delimiters-depth-4-face nil :foreground "#D2A6FF")
  (set-face-attribute 'rainbow-delimiters-depth-5-face nil :foreground "#39BAE6")
  (set-face-attribute 'rainbow-delimiters-depth-6-face nil :foreground "#FFB454")
  (set-face-attribute 'rainbow-delimiters-depth-7-face nil :foreground "#59C2FF")
  (set-face-attribute 'rainbow-delimiters-depth-8-face nil :foreground "#AAD94C")
  (set-face-attribute 'rainbow-delimiters-depth-9-face nil :foreground "#D2A6FF"))

;; Whitespace handling
(defun rc/set-up-whitespace-handling ()
  (add-to-list 'write-file-functions 'delete-trailing-whitespace))

(let ((hooks '(c-mode-hook
               c-ts-mode-hook
               c++-mode-hook
               c++-ts-mode-hook
               python-mode-hook
               python-ts-mode-hook
               simpc-mode-hook
               emacs-lisp-mode-hook
               java-mode-hook
               lua-mode-hook
               rust-mode-hook
               scala-mode-hook
               markdown-mode-hook
               haskell-mode-hook
               yaml-mode-hook)))
  (dolist (hook hooks)
    (add-hook hook 'rc/set-up-whitespace-handling)))

;; Word wrap
(defun rc/enable-word-wrap ()
  (toggle-word-wrap 1))

(add-hook 'markdown-mode-hook 'rc/enable-word-wrap)

;; Delete word backward without copying to kill-ring
(defun rc/delete-word-backward ()
  (interactive)
  (delete-region (point) (save-excursion (backward-word) (point))))

(global-set-key (kbd "C-<backspace>") 'rc/delete-word-backward)

;; Unfill paragraph
(defun rc/unfill-paragraph ()
  (interactive)
  (let ((fill-column 90002000))
    (fill-paragraph nil)))

(global-set-key (kbd "C-c M-q") 'rc/unfill-paragraph)

;; Auto-save on idle
(setq auto-save-visited-interval 30)
(if (fboundp 'auto-save-visited-mode)
    (auto-save-visited-mode 1)
  (setq auto-save-default t))

;; Grammar and prose
(use-package writegood-mode
  :hook ((text-mode markdown-mode) . writegood-mode))

(add-hook 'text-mode-hook 'flyspell-mode)
(add-hook 'markdown-mode-hook 'flyspell-mode)

(provide 'editing-rc)
