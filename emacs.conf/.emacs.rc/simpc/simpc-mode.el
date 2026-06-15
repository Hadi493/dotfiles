;;; simpc-mode.el --- Simple major mode for editing C files. -*- lexical-binding: t; -*-

(require 'subr-x)

(defvar simpc-mode-syntax-table
  (let ((table (make-syntax-table)))
    ;; C/C++ style comments
    (modify-syntax-entry ?/ ". 124b" table)
    (modify-syntax-entry ?* ". 23" table)
    (modify-syntax-entry ?\n "> b" table)
    ;; Preprocessor stuff?
    (modify-syntax-entry ?# "." table)
    ;; Chars are the same as strings
    (modify-syntax-entry ?' "\"" table)
    ;; Treat <> as punctuation (needed to highlight C++ keywords
    ;; properly in template syntax)
    (modify-syntax-entry ?< "." table)
    (modify-syntax-entry ?> "." table)

    (modify-syntax-entry ?& "." table)
    (modify-syntax-entry ?% "." table)
    table))

(defun simpc-types ()
  '("char" "int" "long" "short" "void" "bool" "float" "double" "signed" "unsigned"
    "char16_t" "char32_t" "char8_t"
    "int8_t" "uint8_t" "int16_t" "uint16_t" "int32_t" "uint32_t" "int64_t" "uint64_t"
    "uintptr_t" "intptr_t" "size_t" "ssize_t" "ptrdiff_t"
    "va_list" "wchar_t"))

(defun simpc-keywords ()
  '("auto" "break" "case" "const" "continue" "default" "do"
    "else" "enum" "extern" "for" "goto" "if" "register"
    "return"  "sizeof" "static" "struct" "switch" "typedef"
    "union"  "volatile" "while" "alignas" "alignof" "and"
    "and_eq" "asm" "atomic_cancel" "atomic_commit" "atomic_noexcept" "bitand"
    "bitor" "catch"  "class" "co_await"
    "co_return" "co_yield" "compl" "concept" "const_cast" "consteval" "constexpr"
    "constinit" "decltype" "delete" "dynamic_cast" "explicit" "export" "false"
    "friend" "inline" "mutable" "namespace" "new" "noexcept" "not" "not_eq"
    "nullptr" "operator" "or" "or_eq" "private" "protected" "public" "reflexpr"
    "reinterpret_cast" "requires" "static_assert" "static_cast" "synchronized"
    "template" "this" "thread_local" "throw" "true" "try" "typeid" "typename"
    "using" "virtual" "xor" "xor_eq"))

(defun simpc-font-lock-keywords ()
  (list
   `("# *\\(warn\\|error\\)" . font-lock-warning-face)
   `("# *[a-zA-Z0-9_]+" . font-lock-preprocessor-face)
   `("# *include\\(?:_next\\)?\\s-+\\(\\(<\\|\"\\).*\\(>\\|\"\\)\\)" . (1 font-lock-string-face))
   `("\\(?:enum\\|struct\\|class\\|namespace\\)\\s-+\\([a-zA-Z0-9_]+\\)" . (1 font-lock-type-face))
   `(,(regexp-opt (simpc-keywords) 'symbols) . font-lock-keyword-face)
   `(,(regexp-opt (simpc-types) 'symbols) . font-lock-type-face)
   ;; Function names
   '("\\b\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\s-*(" 1 font-lock-function-name-face)
   ;; Constants and numbers
   '("\\b[0-9]+\\b" . font-lock-constant-face)
   '("\\b0x[0-9a-fA-F]+\\b" . font-lock-constant-face)
   '("\\b[A-Z_][A-Z0-9_]+\\b" . font-lock-constant-face)))

(defun simpc--previous-non-empty-line ()
  "Returns either NIL when there is no such line or a pair (line . indentation)"
  (save-excursion
    (move-beginning-of-line nil)
    (if (bobp)
        nil
      (forward-line -1)
      (while (and (not (bobp))
                  (string-empty-p
                   (string-trim-right
                    (thing-at-point 'line t))))
        (forward-line -1))

      (let ((line (thing-at-point 'line t)))
        (if (or (not line) (string-empty-p (string-trim-right line)))
            nil
          (cons line (current-indentation)))))))

(defun simpc--desired-indentation ()
  (let ((prev (simpc--previous-non-empty-line)))
    (if (not prev)
        0
      (let ((indent-len 4)
            (cur-line (string-trim-left (string-trim-right (thing-at-point 'line t))))
            (prev-line (string-trim-left (string-trim-right (car prev))))
            (prev-indent (cdr prev)))
        (cond
         ;; Preprocessor directive → column 0
         ((string-prefix-p "#" cur-line)
          0)
         ;; Indent after {
         ((string-suffix-p "{" prev-line)
          (if (string-prefix-p "}" cur-line)
              prev-indent
            (+ prev-indent indent-len)))
         ;; Outdent before }
         ((string-prefix-p "}" cur-line)
          (max (- prev-indent indent-len) 0))
         ;; else/while/catch after } → outdent to match if/do/try level
         ((and (string-prefix-p "}" (string-trim-left prev-line))
               (string-match-p "^\\(else\\|while\\|catch\\)\\b" cur-line))
          (max (- prev-indent indent-len) 0))
         ;; Indent after if/for/while/else WITHOUT braces
         ((and (string-match-p "^\\(if\\|for\\|while\\|else\\)\\b" prev-line)
               (not (string-suffix-p "{" prev-line))
               (not (string-suffix-p ";" prev-line)))
          (+ prev-indent indent-len))
         ;; Switch/case
         ((string-match-p "^switch\\s-*(" prev-line)
          prev-indent)
         ((string-suffix-p ":" prev-line)
          (if (string-match-p "^\\(case\\|default\\)\\b" cur-line)
              prev-indent
            (+ prev-indent indent-len)))
         ((string-match-p "^\\(case\\|default\\)\\b" cur-line)
          (max (- prev-indent indent-len) 0))
         (t prev-indent))))))

(defun simpc-indent-line ()
  (interactive)
  (let* ((desired-indentation
          (simpc--desired-indentation))
         (n (max (- (current-column) (current-indentation)) 0)))
    (indent-line-to desired-indentation)
    (forward-char n)))

(define-derived-mode simpc-mode prog-mode "Simple C"
  "Simple major mode for editing C files."
  :syntax-table simpc-mode-syntax-table
  (setq-local font-lock-defaults '(simpc-font-lock-keywords))
  (setq-local indent-line-function 'simpc-indent-line)
  (setq-local comment-start "// ")
  (setq-local comment-end ""))

(provide 'simpc-mode)
