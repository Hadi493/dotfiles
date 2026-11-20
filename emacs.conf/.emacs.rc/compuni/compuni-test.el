;;; compuni-test.el --- Tests for compuni -*- lexical-binding: t; -*-

;;; Code:

(require 'ert)
(require 'cl-lib)
(require 'compuni)

(defun compuni-test--make-sample-buffer ()
  "Create a temporary dataset buffer with deterministic entries."
  (let ((buf (generate-new-buffer " *compuni-test-sample*")))
    (with-current-buffer buf
      (insert "greek small letter lambda\tλ\n"
              "greek capital letter lambda\tΛ\n"
              "rightwards arrow\t→\n"
              "leftwards arrow\t←\n"
              "plus-minus sign\t±\n"
              "grinning face\t😀\n"))
    buf))

(defmacro compuni-test--with-sample-buffer (var &rest body)
  "Bind VAR to a fresh sample dataset buffer, execute BODY, and kill VAR."
  (declare (indent 1))
  `(let ((,var (compuni-test--make-sample-buffer)))
     (unwind-protect
         (progn ,@body)
       (when (buffer-live-p ,var)
         (kill-buffer ,var)))))

;;; Search Engine Tests

(ert-deftest compuni-test-filter-single-word-case-insensitive ()
  (compuni-test--with-sample-buffer buf
    (pcase-let ((`(,res . ,complete) (compuni--filter-buffer "LAMBDA" buf 50)))
      (should complete)
      (should (= (length res) 2))
      (should (member "greek small letter lambda" res))
      (should (member "greek capital letter lambda" res)))))

(ert-deftest compuni-test-filter-multi-word-any-order ()
  (compuni-test--with-sample-buffer buf
    (let ((res1 (car (compuni--filter-buffer "lambda small" buf 50)))
          (res2 (car (compuni--filter-buffer "small   lambda" buf 50))))
      (should (equal res1 '("greek small letter lambda")))
      (should (equal res2 '("greek small letter lambda"))))))

(ert-deftest compuni-test-filter-empty-query-returns-up-to-limit ()
  (compuni-test--with-sample-buffer buf
    (pcase-let ((`(,res . ,complete) (compuni--filter-buffer "   " buf 3)))
      (should (= (length res) 3))
      (should-not complete))))

(ert-deftest compuni-test-filter-respects-max-results ()
  (compuni-test--with-sample-buffer buf
    (pcase-let ((`(,res . ,complete) (compuni--filter-buffer "a" buf 2)))
      (should (= (length res) 2))
      (should-not complete))))

(ert-deftest compuni-test-filter-no-matches ()
  (compuni-test--with-sample-buffer buf
    (pcase-let ((`(,res . ,complete) (compuni--filter-buffer "nonexistent" buf 50)))
      (should-not res)
      (should complete))))

(ert-deftest compuni-test-filter-literal-special-chars ()
  (compuni-test--with-sample-buffer buf
    (should (equal (car (compuni--filter-buffer "plus-minus" buf 50))
                   '("plus-minus sign")))
    (should-not (car (compuni--filter-buffer "[invalid*regex+" buf 50)))))

(ert-deftest compuni-test-filter-ignores-glyph-column ()
  (compuni-test--with-sample-buffer buf
    (should-not (car (compuni--filter-buffer "λ" buf 50)))))

;;; Match Highlighting & Margin Tests

(ert-deftest compuni-test-match-regions-multi-word-and-repeated ()
  (should (equal (compuni--match-regions "greek small letter lambda" '("lambda" "small"))
                 '((6 . 11) (19 . 25))))
  (should (equal (compuni--match-regions "lambda" '("a"))
                 '((1 . 2) (5 . 6))))
  (should (equal (compuni--match-regions "lambda" '("lam" "amb"))
                 '((0 . 4)))))

(ert-deftest compuni-test-sanitize-glyph-for-display ()
  (should (equal (compuni--sanitize-glyph-for-display "λ") "λ"))
  (should (equal (compuni--sanitize-glyph-for-display "\n") "·"))
  (should (equal (compuni--sanitize-glyph-for-display "\t") "·"))
  (should (equal (compuni--sanitize-glyph-for-display "\u0301") "◌\u0301")))

(ert-deftest compuni-test-glyph-scale-for-char ()
  (clrhash compuni--font-height-cache)
  (cl-letf (((symbol-function 'face-font)
             (lambda (_face &optional _frame ch)
               (pcase ch
                 (?a "mono-16")
                 (?λ "symbol-32")
                 (?😀 "emoji-64"))))
            ((symbol-function 'font-info)
             (lambda (name)
               (pcase name
                 ("mono-16" [nil nil 16 16])
                 ("symbol-32" [nil nil 32 32])
                 ("emoji-64" [nil nil 64 64])))))
    ;; Already fits -> nil (no scaling).
    (should-not (compuni--glyph-scale-for-char ?a 16))
    ;; 2x taller -> scaled to 0.5.
    (should (= (compuni--glyph-scale-for-char ?λ 16) 0.5))
    ;; 4x taller -> clamped at minimum 0.45.
    (should (= (compuni--glyph-scale-for-char ?😀 16) 0.45)))
  (clrhash compuni--font-height-cache))

(ert-deftest compuni-test-format-margin-tty-and-gui ()
  (let ((cand (compuni--make-candidate "greek small letter lambda" "λ")))
    (cl-letf (((symbol-function 'display-graphic-p) (lambda (&rest _) nil)))
      (let ((m (compuni--format-margin cand nil)))
        (should (equal (substring-no-properties m) " λ "))
        (should (eq (get-text-property 0 'face m) 'company-tooltip))
        (should (equal (get-text-property 1 'face m)
                       '(company-tooltip-annotation company-tooltip))))
      (let ((m-sel (compuni--format-margin cand t)))
        (should (eq (get-text-property 0 'face m-sel) 'company-tooltip-selection))
        (should (equal (get-text-property 1 'face m-sel)
                       '(company-tooltip-annotation-selection company-tooltip-selection)))))
    (cl-letf (((symbol-function 'display-graphic-p) (lambda (&rest _) t))
              ((symbol-function 'string-pixel-width) (lambda (_s) 8))
              ((symbol-function 'compuni--glyph-scale-for-char) (lambda (_ch _h) 0.6)))
      (let ((m (compuni--format-margin cand nil)))
        (should (equal (substring-no-properties m) " λ "))
        (should (equal (get-text-property 1 'face m)
                       '((:height 0.6) compuni-glyph-face
                         company-tooltip-annotation company-tooltip)))
        (should (equal (get-text-property 2 'display m)
                       '(space :width (16)))))
      (let ((m-sel (compuni--format-margin cand t)))
        (should (equal (get-text-property 1 'face m-sel)
                       '((:height 0.6) compuni-glyph-face
                         company-tooltip-annotation-selection company-tooltip-selection)))))))

;;; Incremental Narrowing Tests

(ert-deftest compuni-test-incremental-narrowing-and-widening ()
  (compuni-test--with-sample-buffer buf
    (let ((session (make-compuni--session :buffer buf))
          (buffer-scans 0))
      (cl-letf* ((orig (symbol-function 'compuni--filter-buffer))
                 ((symbol-function 'compuni--filter-buffer)
                  (lambda (&rest args)
                    (setq buffer-scans (1+ buffer-scans))
                    (apply orig args))))
        (should (= (length (compuni--query-session "lambda" session)) 2))
        (should (= buffer-scans 1))
        (should (equal (compuni--query-session "lambda small" session)
                       '("greek small letter lambda")))
        (should (= buffer-scans 1))
        (should (= (length (compuni--query-session "lambda" session)) 2))
        (should (= buffer-scans 2))))))

(ert-deftest compuni-test-truncated-query-does-not-narrow-incomplete-set ()
  (compuni-test--with-sample-buffer buf
    (let ((compuni-max-candidates 2)
          (session (make-compuni--session :buffer buf)))
      (should (= (length (compuni--query-session "a" session)) 2))
      (should-not (compuni--session-last-complete session))
      (let ((res (compuni--query-session "arrow" session)))
        (should (= (length res) 2))
        (should (member "rightwards arrow" res))
        (should (member "leftwards arrow" res))))))

;;; Data Provider & Performance Tests

(ert-deftest compuni-test-unicode-buffer-loads-and-caches ()
  (compuni-clear-cache)
  (let* ((buf1 (compuni--get-unicode-buffer))
         (buf2 (compuni--get-unicode-buffer))
         (res (car (compuni--filter-buffer "greek small letter lambda" buf1 50))))
    (should (eq buf1 buf2))
    (should (> (buffer-size buf1) 10000))
    (should (member "greek small letter lambda" res))
    (should (equal (get-text-property 0 'compuni-char
                                      (car (member "greek small letter lambda" res)))
                   "λ"))))

(ert-deftest compuni-test-emoji-buffer-loads-and-caches ()
  (compuni-clear-cache)
  (let* ((buf1 (compuni--get-emoji-buffer))
         (buf2 (compuni--get-emoji-buffer))
         (res (car (compuni--filter-buffer "grinning" buf1 50))))
    (should (eq buf1 buf2))
    (should (> (buffer-size buf1) 1000))
    (should res)
    (should (stringp (get-text-property 0 'compuni-char (car res))))))

(ert-deftest compuni-test-unicode-search-latency ()
  (compuni-clear-cache)
  (let* ((buf (compuni--get-unicode-buffer))
         (start (float-time))
         (res (car (compuni--filter-buffer "lambda small" buf 50)))
         (elapsed-ms (* 1000.0 (- (float-time) start))))
    (should (member "greek small letter lambda" res))
    (should (< elapsed-ms 100.0))))

;;; Backend Protocol Tests

(ert-deftest compuni-test-backend-prefix-tracks-spaces ()
  (compuni-test--with-sample-buffer buf
    (with-temp-buffer
      (insert "hello lambda")
      (let ((compuni--active-session
             (make-compuni--session :buffer buf
                                    :start-marker (copy-marker 7)
                                    :prev-company-mode nil)))
        (should (equal (compuni--company-backend 'prefix) '("lambda" . t)))
        (insert " small")
        (should (equal (compuni--company-backend 'prefix) '("lambda small" . t)))
        (goto-char 3)
        (should-not (compuni--company-backend 'prefix))))))

(ert-deftest compuni-test-backend-metadata-and-match ()
  (compuni-test--with-sample-buffer buf
    (let ((cand (compuni--make-candidate "greek small letter lambda" "λ"))
          (compuni--active-session
           (make-compuni--session :buffer buf
                                  :last-terms '("lambda" "small"))))
      (should (eq (compuni--company-backend 'no-cache) t))
      (should (eq (compuni--company-backend 'ignore-case) t))
      (should (equal (compuni--company-backend 'match cand)
                     '((6 . 11) (19 . 25)))))))

(ert-deftest compuni-test-backend-post-completion-replaces-text ()
  (compuni-test--with-sample-buffer buf
    (with-temp-buffer
      (insert "value: ")
      (let* ((start (point))
             (cand (compuni--make-candidate "greek small letter lambda" "λ"))
             (compuni--active-session
              (make-compuni--session :buffer buf
                                     :start-marker (copy-marker start)
                                     :prev-company-mode nil)))
        (insert cand)
        (compuni--company-backend 'post-completion cand)
        (should (equal (buffer-string) "value: λ"))))))

;;; Lifecycle & Safeguard Tests

(ert-deftest compuni-test-lifecycle-restores-company-mode-off ()
  (compuni-test--with-sample-buffer buf
    (with-temp-buffer
      (insert "lambda")
      (company-mode -1)
      (let ((orig-backends (copy-sequence company-backends)))
        (cl-letf (((symbol-function 'company-begin-backend)
                   (lambda (_backend)
                     (setq company-candidates '("greek small letter lambda")))))
          (compuni--start (lambda () buf))
          (should (bound-and-true-p company-mode))
          (should compuni--active-session)
          (should (equal company-backends orig-backends))
          (when (boundp 'company-format-margin-function)
            (should (eq company-format-margin-function #'compuni--format-margin)))
          (should (memq #'compuni--cleanup company-after-completion-hook))
          (let ((marker (compuni--session-start-marker compuni--active-session)))
            (run-hook-with-args 'company-after-completion-hook nil)
            (should-not (bound-and-true-p company-mode))
            (should-not compuni--active-session)
            (should-not (marker-position marker))
            (when (boundp 'company-format-margin-function)
              (should-not (local-variable-p 'company-format-margin-function)))
            (should-not (memq #'compuni--cleanup company-after-completion-hook))))))))

(ert-deftest compuni-test-lifecycle-preserves-company-mode-on ()
  (compuni-test--with-sample-buffer buf
    (with-temp-buffer
      (insert "lambda")
      (company-mode 1)
      (let ((orig-backends (copy-sequence company-backends)))
        (cl-letf (((symbol-function 'company-begin-backend)
                   (lambda (_backend)
                     (setq company-candidates '("greek small letter lambda")))))
          (compuni--start (lambda () buf))
          (should (bound-and-true-p company-mode))
          (run-hook-with-args 'company-after-completion-hook nil)
          (should (bound-and-true-p company-mode))
          (should-not compuni--active-session)
          (should (equal company-backends orig-backends)))))))

(ert-deftest compuni-test-safeguard-cleans-up-on-zero-matches ()
  (compuni-test--with-sample-buffer buf
    (with-temp-buffer
      (insert "zzzznotfound")
      (company-mode -1)
      (cl-letf (((symbol-function 'company-begin-backend)
                 (lambda (_backend)
                   (setq company-candidates nil))))
        (compuni--start (lambda () buf))
        (should-not (bound-and-true-p company-mode))
        (should-not compuni--active-session)
        (should-not (memq #'compuni--cleanup company-after-completion-hook))))))

(ert-deftest compuni-test-start-handles-middle-of-word-and-region ()
  (compuni-test--with-sample-buffer buf
    (with-temp-buffer
      (insert "foo lambda bar")
      (goto-char 8)
      (cl-letf (((symbol-function 'company-begin-backend)
                 (lambda (_backend)
                   (setq company-candidates '("greek small letter lambda")))))
        (compuni--start (lambda () buf))
        (should (equal (compuni--company-backend 'prefix) '("lambda" . t)))
        (compuni--cleanup)))
    (with-temp-buffer
      (insert "foo lambda small bar")
      (transient-mark-mode 1)
      (set-mark 5)
      (goto-char 17)
      (cl-letf (((symbol-function 'company-begin-backend)
                 (lambda (_backend)
                   (setq company-candidates '("greek small letter lambda")))))
        (compuni--start (lambda () buf))
        (should (equal (compuni--company-backend 'prefix) '("lambda small" . t)))
        (should-not (use-region-p))
        (compuni--cleanup)))))

(ert-deftest compuni-test-start-survives-preexisting-company-session ()
  (compuni-test--with-sample-buffer buf
    (with-temp-buffer
      (insert "lambda")
      (company-mode 1)
      (let ((cancelled-prior nil))
        (cl-letf (((symbol-function 'company-cancel)
                   (lambda (&rest _)
                     (unless cancelled-prior
                       (setq cancelled-prior t)
                       (run-hook-with-args 'company-after-completion-hook nil))))
                  ((symbol-function 'company-begin-backend)
                   (lambda (_backend)
                     (company-cancel)
                     (should compuni--active-session)
                     (should (equal (compuni--company-backend 'prefix) '("lambda" . t)))
                     (setq company-candidates
                           (compuni--company-backend 'candidates "lambda")))))
          (compuni--start (lambda () buf))
          (should cancelled-prior)
          (should compuni--active-session)
          (should (= (length company-candidates) 2))
          (compuni--cleanup))))))

(provide 'compuni-test)

;;; compuni-test.el ends here
