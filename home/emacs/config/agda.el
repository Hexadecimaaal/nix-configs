(require 'agda2-mode)
;; (setq agda-input-inherit
;;    '(("TeX" agda-input-compose
;;       (agda-input-drop
;;        '("geq" "leq" "bullet" "qed" "par"))
;;       (agda-input-or
;;        (agda-input-drop-prefix "¥")
;;        (agda-input-or
;; 	(agda-input-compose
;; 	 (agda-input-drop
;; 	  '("^l" "^o" "^r" "^v"))
;; 	 (agda-input-prefix "^"))
;; 	(agda-input-prefix "_"))))))

;; (setq agda-input-tweak-all
;;    '(agda-input-compose
;;      (agda-input-prepend "¥")
;;      (agda-input-nonempty)))

(setq agda2-backend "GHCNoMain")
(setq agda2-highlight-face-groups 'default-faces)

;;  '(agda2-highlight-catchall-clause-face ((t (:background "dim gray"))))
;;  '(agda2-highlight-coinductive-constructor-face ((t (:foreground "light goldenrod"))))
;;  '(agda2-highlight-coverage-problem-face ((t (:background "chocolate"))))
;;  '(agda2-highlight-datatype-face ((t (:foreground "aquamarine"))))
;;  '(agda2-highlight-deadcode-face ((t (:background "dim gray"))))
;;  '(agda2-highlight-function-face ((t (:foreground "medium aquamarine"))))
;;  '(agda2-highlight-inductive-constructor-face ((t (:foreground "lawn green"))))
;;  '(agda2-highlight-keyword-face ((t (:foreground "orange"))))
;;  '(agda2-highlight-macro-face ((t (:foreground "cyan"))))
;;  '(agda2-highlight-module-face ((t (:foreground "plum"))))
;;  '(agda2-highlight-number-face ((t (:foreground "plum"))))
;;  '(agda2-highlight-positivity-problem-face ((t (:background "orange red"))))
;;  '(agda2-highlight-postulate-face ((t (:foreground "cyan"))))
;;  '(agda2-highlight-primitive-face ((t (:foreground "cyan"))))
;;  '(agda2-highlight-primitive-type-face ((t (:foreground "cyan"))))
;;  '(agda2-highlight-record-face ((t (:foreground "cyan"))))
;;  '(agda2-highlight-string-face ((t (:foreground "lime green"))))
;;  '(agda2-highlight-termination-problem-face ((t (:background "dark red"))))
;;  '(agda2-highlight-unsolved-constraint-face ((t (:background "yellow4"))))
;;  '(agda2-highlight-unsolved-meta-face ((t (:background "yellow4"))))

(ignore-errors (load-file (let ((coding-system-for-read 'utf-8))
                (shell-command-to-string "agda-mode locate"))))
