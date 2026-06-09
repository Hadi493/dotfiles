;;; PDF support using pdf-tools (deferred loading)

(use-package pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :magic ("%PDF" . pdf-view-mode)
  :config
  (pdf-tools-install :no-query)
  (add-to-list 'pdf-view-incompatible-modes 'display-line-numbers-mode)
  :hook (pdf-view-mode . (lambda ()
                           (pdf-annot-minor-mode 1)
                           (pdf-view-midnight-minor-mode 1)
                           (display-line-numbers-mode -1)))
  :bind (:map pdf-view-mode-map
              ("C-c C-m" . pdf-view-midnight-minor-mode)))

(provide 'pdf-rc)
