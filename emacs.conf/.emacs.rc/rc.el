;;; rc.el --- Package setup -*- lexical-binding: t; -*-
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
;; (add-to-list 'package-archives
;;              '("melpa-stable" . "https://stable.melpa.org/packages/") t)

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
  (let ((theme-package (->> theme
                            (symbol-name)
                            (funcall (-flip #'concat) "-theme")
                            (intern))))
    (rc/require theme-package)
    (load-theme theme t)))

(defun -flip (fn)
  "Flip a two-argument function so it can be used as a single-arg transformer on the second argument.
This is a compatibility shim for dash-functional, which is deprecated."
  (lambda (x y) (funcall fn y x)))

(defun ->> (x &rest forms)
  "Thread x through forms.
This is a compatibility shim for dash-functional, which is deprecated."
  (dolist (form forms)
    (setq x (funcall form x)))
  x)

(rc/require 'dash)
(require 'dash)

(rc/require 'dash-functional)
(when (featurep 'dash-functional)
  (require 'dash-functional))

(when (ignore-errors (require '-- nil t))
  nil)
