;;; Completion configuration (Vertico + Consult + Corfu)

;; NOTE: Remove old packages:
;;   M-x package-delete RET helm RET
;;   M-x package-delete RET helm-core RET
;;   M-x package-delete RET smex RET
;;   M-x package-delete RET ido-completing-read+ RET

(use-package vertico
  :config
  (vertico-mode)
  (setq vertico-cycle t))

(use-package marginalia
  :config
  (marginalia-mode))

(use-package consult
  :bind (("C-x b" . consult-buffer)
         ("C-s" . consult-line)
         ("C-c h g g" . consult-git-grep)
         ("C-c h f" . consult-find)
         ("C-c h r" . consult-recent-file)
         ("C-c h a" . consult-org-agenda)
         ("M-y" . consult-yank-pop))
  :config
  (setq consult-narrow-key "<"))

(use-package orderless
  :config
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles . (partial-completion))))))

(use-package corfu
  :config
  (global-corfu-mode)
  (setq corfu-auto t
        corfu-cycle t
        corfu-idle-delay 0.08
        corfu-min-width 60
        corfu-count 12
        corfu-on-exact-match nil))

(use-package cape
  :config
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-elisp-symbol))

;; C/C++ headers via company-c-headers bridged to Corfu
(use-package company-c-headers
  :after corfu
  :config
  (defun rc/enable-c-headers ()
    (setq-local completion-at-point-functions
                (cons (cape-company-to-capf #'company-c-headers)
                      completion-at-point-functions)))
  (add-hook 'c-mode-hook #'rc/enable-c-headers)
  (add-hook 'c-ts-mode-hook #'rc/enable-c-headers)
  (add-hook 'c++-mode-hook #'rc/enable-c-headers))

(provide 'completion-rc)
