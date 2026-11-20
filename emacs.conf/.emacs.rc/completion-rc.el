;;; completion-rc.el --- Completion configuration (Vertico, Helm, Company) -*- lexical-binding: t; -*-

;; Ido is disabled — vertico replaces it
(ido-mode -1)
(ido-everywhere -1)
(when (fboundp 'ido-ubiquitous-mode)
  (ido-ubiquitous-mode -1))

;;; Helm
(rc/require 'helm)
(setq helm-ff-transformer-show-only-basename nil)

(global-set-key (kbd "C-c h t") 'helm-cmd-t)
(global-set-key (kbd "C-c h g g") 'helm-git-grep)
(global-set-key (kbd "C-c h g l") 'helm-ls-git-ls)
(global-set-key (kbd "C-c h f") 'helm-find)
(global-set-key (kbd "C-c h a") 'helm-org-agenda-files-headings)
(global-set-key (kbd "C-c h r") 'helm-recentf)

;; Company
(rc/require 'company 'company-c-headers)
(require 'company nil t)
(global-company-mode)

;; Add standard header paths for C/C++ completion
(setq company-c-headers-path-system '("/usr/include" "/usr/local/include"))

;; Compuni — unicode/emoji insertion; vendored in .emacs.rc/compuni/ (not on MELPA)
(use-package compuni
  :ensure nil
  :load-path "~/.emacs.rc/compuni"
  :after company
  :commands (compuni-insert-unicode compuni-insert-emoji)
  :bind (("C-c u u" . compuni-insert-unicode)
         ("C-c u e" . compuni-insert-emoji))
  :custom
  (compuni-max-candidates 50))

;; Marginalia — minibuffer annotations
(rc/require 'marginalia)
(when (require 'marginalia nil 'noerror)
  (marginalia-mode 1))

;; Consult — enhanced completion commands
(rc/require 'consult)

;; Orderless — flexible completion style
(rc/require 'orderless)
(when (require 'orderless nil 'noerror)
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles basic partial-completion)))))

;; Better backend grouping: grouped backends are tried until one returns results
(setq company-backends '((company-capf company-c-headers company-files company-keywords)
                         (company-dabbrev company-dabbrev-code company-ispell)))

;; Snappier feel
(setq company-idle-delay 0.05
      company-minimum-prefix-length 2
      company-dabbrev-downcase nil
      company-dabbrev-ignore-case nil
      company-dabbrev-other-buffers t)

(add-hook 'text-mode-hook 'company-mode)
(add-hook 'markdown-mode-hook 'company-mode)

(add-hook 'tuareg-mode-hook
          (lambda ()
            (interactive)
            (company-mode 1)))

(provide 'completion-rc)
