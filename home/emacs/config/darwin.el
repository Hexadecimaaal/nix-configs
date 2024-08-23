(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
(add-to-list 'default-frame-alist '(ns-appearance . dark))
(setq-default
  ns-use-proxy-icon nil)

(defadvice handle-delete-frame (around my-handle-delete-frame-advice activate)
  "Hide Emacs instead of closing the last frame"
  (let ((frame   (posn-window (event-start event)))
        (numfrs  (length (frame-list))))
    (if (> numfrs 1)
        ad-do-it
      (do-applescript "tell application \"System Events\" to tell process \"Emacs\" to set visible to false"))))

(setq-default
  ns-command-modifier 'super
  ns-alternate-modifier 'meta
  ns-right-alternate-modifier 'none
  ns-use-mwheel-acceleration t
  ns-use-mwheel-momentum t)
