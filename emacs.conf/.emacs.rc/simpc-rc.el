;;; simpc-mode configuration

(add-to-list 'load-path (expand-file-name "~/.emacs.rc/simpc/"))
(require 'simpc-mode nil t)

(add-to-list 'auto-mode-alist '("\\.[hc]\\(pp\\)?\\'" . simpc-mode))

(defun astyle-buffer (&optional justify)
  "Format the current buffer using astyle."
  (interactive)
  (if (executable-find "astyle")
      (let ((saved-line-number (line-number-at-pos)))
        (shell-command-on-region
         (point-min)
         (point-max)
         "astyle --style=kr"
         nil
         t)
        (goto-line saved-line-number))
    (message "astyle not found in PATH")))

(add-hook 'simpc-mode-hook
          (lambda ()
            (interactive)
            (setq-local fill-paragraph-function 'astyle-buffer)))

(provide 'simpc-rc)
