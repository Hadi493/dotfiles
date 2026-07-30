;;; urdish.el --- Phonetic Urdu input (Urdish/Arabizi style) -*- lexical-binding: t; -*-

;; Type Urdu phonetically using Latin letters.
;;   "urdish" -> "اردش"    "kitab" -> "کتاب"    "salam" -> "سلام"
;;   "shukria" -> "شکریہ"  "khuda" -> "خدا"    "ghar" -> "گھر"
;;   "aap" -> "آپ"         "hamaara" -> "ہمارا" "tumhaara" -> "تمہارا"
;;   "chand" -> "چاند"     "zindagi" -> "زندگی" "dil" -> "دل"
;;
;; Urdu-specific: T->ٹ, D->ڈ, R->ڑ, N->ں, e->ے, y->ی, h->ہ, H->ھ

;;; Code:

(require 'quail)

(quail-define-package
 "urdish" "Urdu" "ارد" t
 "Phonetic Urdu (Urdish): type Latin phonetically.
 Examples:
   urdu -> اردو         salam -> سلام       kitab -> کتاب
   shukria -> شکریہ     khuda -> خدا        ghar -> گھر
   aap -> آپ            chand -> چاند       zindagi -> زندگی
   dil -> دل            baat -> بات         kaam -> کام
 T->ٹ D->ڈ R->ڑ N->ں e->ے y->ی h->ہ H->ھ
 Diacritics (prefix o): oa->َ ob->ِ op->ُ oS->ّ
"
 nil t t t t nil nil nil nil nil t)

(quail-define-rules
 ;; Urdu-specific letters
 ("T" "ٹ")
 ("D" "ڈ")
 ("R" "ڑ")
 ("N" "ں")
 ("e" "ے")
 ("E" "ۓ")
 ("y" "ی")
 ("h" "ہ")
 ("H" "ھ")
 ("p" "پ")
 ("g" "گ")
 ("c" "چ")

 ;; Digraphs (must come before single letters)
 ("sh" "ش")
 ("ch" "چ")
 ("kh" "خ")
 ("gh" "غ")
 ("zh" "ژ")
 ("th" "ث")
 ("dh" "ذ")
 ("ah" "ہ")

 ;; Hamza
 ("'" "ء")
 ("'a" "أ")
 ("'i" "إ")
 ("'u" "ؤ")
 ("'y" "ئ")
 ("A'" "آ")

 ;; Long vowels (before single)
 ("aa" "ا")
 ("ii" "ی")
 ("uu" "و")
 ("a" "ا")
 ("i" "ی")
 ("u" "و")

 ;; Diphthongs
 ("ay" "ۓ")
 ("ai" "ۓ")
 ("aw" "او")
 ("au" "او")

 ;; Single consonants
 ("b" "ب")
 ("t" "ت")
 ("j" "ج")
 ("d" "د")
 ("r" "ر")
 ("z" "ز")
 ("s" "س")
 ("f" "ف")
 ("k" "ک")
 ("l" "ل")
 ("m" "م")
 ("n" "ن")
 ("w" "و")

 ;; Case variants for emphatic/missing
 ("S" "ص")
 ("Z" "ض")
 ("s" "س")
 ("z" "ز")

 ;; Vowel diacritics (prefix o = zabar/zer/pesh)
 ("oa" "َ")
 ("ob" "ِ")
 ("op" "ُ")
 ("oS" "ّ")
 ("oj" "ْ")
 ("ok" "ٰ")

 ;; Numbers
 ("0" "۰")
 ("1" "۱")
 ("2" "۲")
 ("3" "۳")
 ("4" "۴")
 ("5" "۵")
 ("6" "۶")
 ("7" "۷")
 ("8" "۸")
 ("9" "۹")

 ;; Article
 ("al-" "ال")
 ("as-" "ال")
 ("ad-" "ال")
 ("at-" "ال")
 ("az-" "ال")
 ("al" "ال")

 ;; Punctuation
 ("," "،")
 ("?" "؟")
 (";" "؛"))

(provide 'urdish)

;;; urdish.el ends here