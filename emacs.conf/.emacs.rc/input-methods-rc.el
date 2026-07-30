;;; Input Methods Configuration
;; Multilingual input support with Bengali (Banglish/ITRANS) and Arabic (Arabish)

(require 'quail)

;; Load custom Arabish (phonetic Arabic)
(load "~/.emacs.rc/arabish.el")

;; Register Bengali input methods
(register-input-method
 "bengali-itrans" "Bengali" 'quail-use-package
 "BngIT" "Bengali ITRANS (Banglish phonetic: ami -> আমি)"
 "quail/indian")

(register-input-method
 "bengali-probhat" "Bengali" 'quail-use-package
 "BngPB" "Probhat keyboard for Bengali/Bangla"
 "quail/indian")

(register-input-method
 "bengali-inscript" "Bengali" 'quail-use-package
 "BngIS" "Bengali keyboard Inscript"
 "quail/indian")

;; Arabic input methods
(register-input-method
 "arabic" "Arabic" 'quail-use-package
 "ArAB" "Arabic keyboard"
 "quail/arabic")

(register-input-method
 "arabish" "Arabic" 'quail-use-package
 "ArPH" "Arabic Phonetic (Arabish: ana -> أنا, kitab -> كتاب)"
 "arabish")

;; Keybindings for input method switching
(global-set-key (kbd "C-\\") 'toggle-input-method)
(global-set-key (kbd "C-x \\") 'set-input-method)

;; Convenient keybindings for Bengali
(global-set-key (kbd "C-c b i") (lambda () (interactive) (set-input-method "bengali-itrans")))
(global-set-key (kbd "C-c b p") (lambda () (interactive) (set-input-method "bengali-probhat")))
(global-set-key (kbd "C-c b s") (lambda () (interactive) (set-input-method "bengali-inscript")))

;; Arabic keybindings
(global-set-key (kbd "C-c a a") (lambda () (interactive) (set-input-method "arabic")))
(global-set-key (kbd "C-c a p") (lambda () (interactive) (set-input-method "arabish")))

;; Toggle between last two input methods
(global-set-key (kbd "C-c C-\\") 'toggle-input-method)

;; Helper: Show available input methods
(defun my/show-input-methods ()
  "Show available input methods for major languages."
  (interactive)
  (let ((methods '("bengali-itrans" "bengali-probhat" "bengali-inscript"
                   "arabic" "arabish"
                   "devanagari-itrans" "tamil-itrans" "gurmukhi-itrans"
                   "japanese-hiragana" "japanese-katakana" "korean-hangul"
                   "chinese-py" "chinese-pinyin" "chinese-4corner")))
    (with-output-to-temp-buffer "*Input Methods*"
      (princ "Available Input Methods:\n\n")
      (dolist (m methods)
        (let* ((info (quail-get-translation m ""))
               (desc (if info (cadr info) "No description")))
          (princ (format "%-25s %s\n" m desc)))))))

(global-set-key (kbd "C-c i") 'my/show-input-methods)

;; Enable input method indicator in mode line
(setq-default input-method-highlight-flag t)

(provide 'input-methods-rc)