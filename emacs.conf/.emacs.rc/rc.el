(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

(eval-when-compile
  (require 'use-package))

(setq use-package-always-ensure t)

(defvar rc/package-contents-refreshed nil)

(defun rc/package-refresh-contents-once ()
  (when (not rc/package-contents-refreshed)
    (setq rc/package-contents-refreshed t)
    (package-refresh-contents)))

(defun rc/require-one-package (package)
  (when (not (package-installed-p package))
    (rc/package-refresh-contents-once)
    (package-install package)))

(defun rc/require (&rest packages)
  (dolist (package packages)
    (rc/require-one-package package)))

(defun rc/require-theme (theme)
  (let ((theme-package (intern (concat (symbol-name theme) "-theme"))))
    (rc/require theme-package)
    (load-theme theme t)))

(provide 'rc)
