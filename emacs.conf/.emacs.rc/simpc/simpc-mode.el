;;; simpc-mode.el --- Simple major mode for editing C files. -*- lexical-binding: t; -*-

;; Derives from c-mode for proper indentation, with custom font-lock.

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
   '("\\b\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\s-*(" 1 font-lock-function-name-face)
   '("\\b[0-9]+\\b" . font-lock-constant-face)
   '("\\b0x[0-9a-fA-F]+\\b" . font-lock-constant-face)
   '("\\b[A-Z_][A-Z0-9_]+\\b" . font-lock-constant-face)))

(define-derived-mode simpc-mode c-mode "Simple C"
  "Simple major mode for editing C files.
Derives from c-mode — inherits proper indentation, only custom font-lock."
  (c-init-language-vars 'c-mode)
  (setq-local font-lock-defaults '(simpc-font-lock-keywords))
  (setq-local comment-start "// ")
  (setq-local comment-end ""))

(provide 'simpc-mode)
