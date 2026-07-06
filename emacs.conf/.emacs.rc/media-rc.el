;;; Video and Media support (requires 'mpv' on the system)

(rc/require 'empv)

(global-set-key (kbd "C-c v y") 'empv-youtube-search)
(global-set-key (kbd "C-c v f") 'empv-play-file)
(global-set-key (kbd "C-c v u") 'empv-play-url)
(global-set-key (kbd "C-c v t") 'empv-toggle)
(global-set-key (kbd "C-c v q") 'empv-exit)
(global-set-key (kbd "C-c v s") 'empv-video-seek)

(defun rc/open-with-mpv ()
  "Open the file at point with mpv."
  (interactive)
  (let ((file (dired-get-filename)))
    (start-process "mpv" nil "mpv" file)))

(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "RET")
    (lambda ()
      (interactive)
      (let ((file (dired-get-filename nil t)))
        (if (and file (string-match-p "\\.\\(mp3\\|mp4\\|webm\\|mkv\\|wav\\|flac\\|mov\\|avi\\)$" file))
            (rc/open-with-mpv)
          (dired-find-file))))))

(provide 'media-rc)
