(defun delete-word (arg)
  "Delete characters forward until encountering the end of a word.
With argument, do this that many times."
  (interactive "p")
  (if (use-region-p)
      (delete-region (region-beginning) (region-end))
    (delete-region (point) (progn (forward-word arg) (point)))))

(defun backward-delete-word (arg)
  "Delete characters backward until encountering the end of a word.
With argument, do this that many times."
  (interactive "p")
  (delete-word (- arg)))

;; (global-set-key (kbd "C-?") 'help-command)
;; (global-set-key (kbd "M-?") 'mark-paragraph)
;; (global-set-key (kbd "C-h") 'delete-backward-char)
;; (global-set-key (kbd "M-h") 'backward-delete-word)
;; (global-set-key (kbd "M-<DEL>") 'backward-delete-word)

(global-set-key (kbd "s-q") 'save-buffers-kill-terminal)
(global-set-key (kbd "s-m") 'suspend-frame)
(global-set-key (kbd "s-<right>") 'next-buffer)
(global-set-key (kbd "s-<left>") 'previous-buffer)
(global-set-key (kbd "s-s") 'save-buffer)
(global-set-key (kbd "s-o") 'find-file)
(global-set-key (kbd "s-w") 'kill-buffer)
(global-set-key (kbd "s-v") 'yank)
(global-set-key (kbd "s-x") 'kill-region)
(global-set-key (kbd "s-c") 'kill-ring-save)
(global-set-key (kbd "s-z") 'undo)
(global-set-key (kbd "s-a") 'mark-whole-buffer)
(global-set-key (kbd "C-s-M-c") (lambda () (interactive) (mac-merge-all-frame-tabs)))
(global-set-key (kbd "C-s-y") (lambda () (interactive) (yank-pop -1)))
(global-set-key (kbd "C-;") 'comment-line)
;; (global-set-key (kbd "¥") (lambda () (interactive) (insert "\\")))
;; (global-set-key (kbd "M-¥") (lambda () (interactive) (insert "¥")))
(put 'downcase-region 'disabled nil)

(global-set-key [mouse-8] 'previous-buffer)
(global-set-key [mouse-9] 'next-buffer)
