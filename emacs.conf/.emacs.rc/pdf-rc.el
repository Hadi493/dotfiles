;;; PDF support using pdf-tools

(rc/require 'pdf-tools)

(pdf-tools-install)

(add-to-list 'pdf-view-incompatible-modes 'display-line-numbers-mode)

(add-to-list 'auto-mode-alist '("\\.pdf\\'" . pdf-view-mode))

(add-hook 'pdf-view-mode-hook (lambda ()
                               (pdf-annot-minor-mode 1)
                               (display-line-numbers-mode -1)))

(add-hook 'pdf-view-mode-hook 'pdf-view-midnight-minor-mode)

(with-eval-after-load 'pdf-view
  (define-key pdf-view-mode-map (kbd "C-c C-m") 'pdf-view-midnight-minor-mode))

(provide 'pdf-rc)
