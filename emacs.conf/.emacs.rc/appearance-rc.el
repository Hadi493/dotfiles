;;; Appearance configuration

(defun rc/get-default-font ()
  (cond
   ((eq system-type 'windows-nt) "Iosevka 20")
   ((eq system-type 'gnu/linux) "Iosevka Term SS04 18")))

(add-to-list 'default-frame-alist `(font . ,(rc/get-default-font)))

(set-fontset-font t '(#xe000 . #xfaff) "Symbols Nerd Font")
(set-fontset-font t '(#xf0000 . #xfffff) "Symbols Nerd Font")

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

;; Optional: load gruber-darker-ayu blend instead (comment above, uncomment below)
(load-theme 'gruber-darker-ayu t)
;; Note: use `load-theme' directly — rc/require-theme would try to install
;; the theme as an ELPA package, which doesn't exist for this custom theme.

(use-package ligature
  :config
  (ligature-set-ligatures 't '("www" "**" "***" "**/" "*>" "*/" "\\\\" "\\\\\\" "%%"
                               "==" "===" "!==" "!= " ">=" "<=" "=>" "=>>" "==>" "=="
                               "&&" "&&&" "||" "|||" "||=" "|=" "||>" "==" "!= "
                               "-> " "->>" "-->" "<-" "<<-" "<--" "<->" "<-->"
                               "++" "+++" "---" "--" "==" "===" "!=" "!=="
                               "<<" ">>" "<<<" ">>>" "<>" "<= " ">= "
                               "::" ":::" ":=" "=:=" "== " "!= " "===" "!=="
                               "!!" "??" ".." "..." "...." ".=" ".-" "__"
                               "##" "###" "####" "#_(" "#{" "#?" "#_" "#!"
                               "~~" "~~>" "~>" "~-" "-~" "~@"
                               "[|" "|]" "{|" "|}" "[<" ">]" "|>" "<|"
                               "||" "|||" "||=" "|=" "||>" "==" "!= "
                               "<_>" "<$>" "<+>" "<*>" "<|>" "<||" "<|||"
                               "<| " " <| " " <|> " " <|| " " <||| "
                               "<$ " " <$ " " <$+> " " <$*> "
                               "/*" "*/" "//" "///"))
  (global-ligature-mode t))

(global-display-line-numbers-mode 1)
(setq-default display-line-numbers-type 'relative)

;; Better mode-line with diagnostics, git info, etc.
(use-package doom-modeline
  :init (doom-modeline-mode 1))

(provide 'appearance-rc)
