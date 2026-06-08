;;; Completion configuration (Ido, Helm, Company, Smex)

;;; Ido
(rc/require 'smex 'ido-completing-read+)
(require 'ido-completing-read+)

(ido-mode 1)
(ido-everywhere 1)
(ido-ubiquitous-mode 1)

(global-set-key (kbd "M-x")     'smex)

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
(require 'company)
(global-company-mode)

;; Add standard header paths for C/C++ completion
(setq company-c-headers-path-system '("/usr/include" "/usr/local/include"))

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
