(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold 80000000
                  gc-cons-percentage 0.1)))

(setq native-comp-deferred-compilation t
      native-comp-async-report-warnings-errors nil)

(setq frame-inhibit-implied-resize t)

(package-initialize)
