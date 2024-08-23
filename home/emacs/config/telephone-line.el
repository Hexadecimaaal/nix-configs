(require 'telephone-line)
(require 'telephone-line-utils)

(telephone-line-defsegment* telephone-line-position-segment-custom ()
  (if (eq major-mode 'paradox-menu-mode)
    (telephone-line-raw mode-line-front-space t)
    `((-3 "%p") ,(concat " %3l:%2" (if (bound-and-true-p column-number-indicator-zero-based) "c" "C")))))

(setq telephone-line-subseparator-faces '())
(setq telephone-line-lhs
  '( ;; (evil   . (telephone-line-evil-tag-segment))
    (accent . (telephone-line-buffer-segment))
    (nil    . (telephone-line-vc-segment
               telephone-line-erc-modified-channels-segment
               telephone-line-projectile-segment))))
(setq telephone-line-rhs
  '((nil    . (telephone-line-flycheck-segment
               telephone-line-misc-info-segment
               telephone-line-minor-mode-segment))
    (accent . (telephone-line-process-segment
               telephone-line-major-mode-segment))
    (nil    . (telephone-line-filesize-segment
               (telephone-line-atom-encoding-segment :args (t))
               (telephone-line-atom-eol-segment :args (t))))
    (accent . (telephone-line-position-segment-custom))))

(telephone-line-mode +1)
