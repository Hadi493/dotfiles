;;; appearance-rc.el --- Appearance configuration -*- lexical-binding: t; -*-

(defun rc/get-default-font ()
  (cond
   ((eq system-type 'windows-nt) "Iosevka ss04 20")
   ((eq system-type 'gnu/linux)
    (or (xft-font-name "Iosevka ss04" 18)
        (xft-font-name "Iosevka Nerd Font" 18)
        (xft-font-name "IosevkaTerm" 18)
        (xft-font-name "IosevkaSS04" 18)
        (xft-font-name "Iosevka SS04" 18)
        (xft-font-name "Iosevka" 18)))))

(defun xft-font-name (family size)
  "Return a font name string for FAMILY at SIZE, in FAMILY-SIZE form.
This is the form Emacs's frame font parameter accepts under Xft/Fontconfig; the old
space-separated form (FAMILY followed by SIZE) is rejected as an invalid font."
  (format "%s-%d"
          (replace-regexp-in-string "^[[:space:]]+|[[:space:]]+$" "" family)
          size))

(add-to-list 'default-frame-alist `(font . ,(rc/get-default-font)))

(when (window-system)
  (set-fontset-font t '(#xe000 . #xfaff) "Symbols Nerd Font")
  (set-fontset-font t '(#xf0000 . #xfffff) "Symbols Nerd Font"))

;; Bangla/Bengali + Arabic/Urdu fonts with system fallbacks (only when a window system is available)
(when (window-system)
  (set-fontset-font t 'bengali (font-spec :family "Likhan"))
  (set-fontset-font t 'bengali (font-spec :family "Noto Sans Bengali") nil 'append)
  (set-fontset-font t 'arabic (font-spec :family "Noto Sans Arabic") nil 'append)
  (set-fontset-font t 'arabic (font-spec :family "Noto Naskh Arabic") nil 'append))

(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(column-number-mode 1)
(show-paren-mode 1)
(electric-pair-mode 1)

(add-to-list 'custom-theme-load-path
             (file-name-as-directory
              (expand-file-name "~/.emacs.rc")))

;; (rc/require-theme 'gruber-darker)
(load-theme 'gruber-darker-ayu t)(when (require 'ligature nil t)
  (ligature-set-ligatures 't '("www" "**" "***" "**/" "*>" "*/" "\\\\" "\\\\\\" "%%"
                               "==" "===" "!==" "!= " ">=" "<=" "=>" "=>>" "==>" "=="
                               "&&" "&&&" "||" "|||" "||=" "|=" "||>" "==" "!="
                               "-> " "->>" "-->" "<-" "<<-" "<--" "<->" "<-->"
                               "++" "+++" "---" "--" "==" "===" "!=" "!=="
                               "<<" ">>" "<<<" ">>>" "<>" "<= " ">= "
                               "::" ":::" ":=" "=:=" "== " "!=" "===" "!=="
                               "!!" "??" ".." "..." "...." ".=" ".-" "__"
                               "##" "###" "####" "#_(" "#{" "#?" "#_" "#!"
                               "~~" "~~>" "~>" "~-" "-~" "~@"
                               "[|" "|]" "{|" "|}" "[<" ">]" "|>" "<|"
                               "||" "|||" "||=" "|=" "||>" "==" "!="
                               "<_>" "<$>" "<+>" "<*>" "<|>" "<||" "<|||"
                               "<| " " <| " " <|> " " <|| " " <||| "
                               "<$ " " <$ " " <$+> " " <$*> "
                               "/*" "*/" "//" "///"))
  (global-ligature-mode t))

(global-display-line-numbers-mode 1)
(setq-default display-line-numbers-type 'relative)

(when (require 'doom-modeline nil t)
  (doom-modeline-mode 1))

(use-package vertico
  :ensure t
  :custom
  (vertico-cycle t)
  :init
  (vertico-mode 1)
  :config
  (require 'vertico-directory)
  (define-key vertico-map (kbd "RET") #'vertico-directory-enter)
  (define-key vertico-map (kbd "DEL") #'vertico-directory-delete-char)
  (define-key vertico-map (kbd "M-DEL") #'vertico-directory-delete-word))

(provide 'appearance-rc)
