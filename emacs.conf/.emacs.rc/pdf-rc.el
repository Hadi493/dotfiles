;;; PDF support using pdf-tools
;;; Note: Requires system dependencies like libpoppler-glib, libpng, etc.

(rc/require 'pdf-tools)

;; Initialize pdf-tools
(pdf-tools-install)

;; Disable line numbers in PDF view (they are incompatible)
(add-to-list 'pdf-view-incompatible-modes 'display-line-numbers-mode)

;; Use pdf-tools for PDF files
(add-to-list 'auto-mode-alist '("\\.pdf\\'" . pdf-view-mode))

;; Better annotation support
(add-hook 'pdf-view-mode-hook (lambda ()
                               (pdf-annot-minor-mode 1)
                               (display-line-numbers-mode -1)))

;; Use midnight mode for dark themes (optional, uncomment to enable by default)
;; (add-hook 'pdf-view-mode-hook (lambda () (pdf-view-midnight-minor-mode)))

;; Keybinding to toggle midnight mode
(with-eval-after-load 'pdf-view
  (define-key pdf-view-mode-map (kbd "C-c C-m") 'pdf-view-midnight-minor-mode))

(provide 'pdf-rc)
