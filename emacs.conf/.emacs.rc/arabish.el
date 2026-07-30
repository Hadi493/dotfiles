;;; arabish.el --- Phonetic Arabic input (Arabish/Arabizi) -*- lexical-binding: t; -*-

;; Copyright (C) 2024-2025 Free Software Foundation, Inc.
;; Author: Based on Arabizi convention
;; Keywords: mule, input method, Arabic, arabizi, phonetic

;;; Commentary:
;; Type Arabic phonetically using Latin letters (Arabizi/Arabish).
;;   "ana" -> "انا"    "anta" -> "انت"    "huwa" -> "هو"
;;   "hiya" -> "هي"    "nahnu" -> "نحن"  "kitab" -> "كتاب"
;;   "al-kitab" -> "الكتاب"
;; Hamza: 'a -> أ, 'i -> إ, 'u -> ؤ, ' -> ء
;; Shadda: ~ or :
;; Ta marbuta: ah -> ة

;;; Code:

(require 'quail)

(quail-define-package
 "arabish" "Arabic" "عرب" t
 "Phonetic Arabic (Arabish/Arabizi): type Latin phonetically.
 Examples:
   ana -> انا        anta -> انت        huwa -> هو
   hiya -> هي        nahnu -> نحن      kitab -> كتاب
   bayt -> بيت       salam -> سلام     shukran -> شكرا
   bismillah -> بسم الله
 Hamza: 'a -> أ, 'i -> إ, 'u -> ؤ, ' -> ء
 Shadda: ~ or :
 Ta marbuta: ah -> ة
"
 nil t t t t nil nil nil nil nil t)

(quail-define-rules
 ("'aa" "آ")
 ("'a" "أ")
 ("'i" "إ")
 ("'u" "ؤ")
 ("'" "ء")
 ("ay" "اي")
 ("aw" "او")
 ("aa" "ا")
 ("ii" "ي")
 ("uu" "و")
 ("a" "ا")
 ("i" "ي")
 ("u" "و")
 ("ah" "ة")
 ("eh" "ة")
 ("ih" "ة")
 ("sh" "ش")
 ("kh" "خ")
 ("dh" "ذ")
 ("th" "ث")
 ("gh" "غ")
 ("~" "ّ")
 (":" "ّ")
 ("b" "ب")
 ("t" "ت")
 ("j" "ج")
 ("d" "د")
 ("r" "ر")
 ("z" "ز")
 ("s" "س")
 ("f" "ف")
 ("k" "ك")
 ("l" "ل")
 ("m" "م")
 ("n" "ن")
 ("h" "ه")
 ("w" "و")
 ("y" "ي")
 ("H" "ح")
 ("S" "ص")
 ("D" "ض")
 ("T" "ط")
 ("Z" "ظ")
 ("E" "ع")
 ("X" "خ")
 ("G" "غ")
 ("q" "ق")
 ("v" "ف")
 ("p" "ب")
 ("0" "٠")
 ("1" "١")
 ("2" "٢")
 ("3" "٣")
 ("4" "٤")
 ("5" "٥")
 ("6" "٦")
 ("7" "٧")
 ("8" "٨")
 ("9" "٩")
 ("al-" "ال")
 ("as-" "ال")
 ("ad-" "ال")
 ("at-" "ال")
 ("az-" "ال")
 ("ar-" "ال")
 ("ash-" "ال")
 ("an-" "ال")
 ("," "،")
 ("?" "؟")
 (";" "؛")
 ("bismillah" "بسم الله")
 ("alhamdulillah" "الحمد لله")
 ("inshallah" "ان شاء الله")
 ("mashallah" "ما شاء الله")
 ("subhanallah" "سبحان الله")
 ("assalamu alaykum" "السلام عليكم"))

(provide 'arabish)

;;; arabish.el ends here