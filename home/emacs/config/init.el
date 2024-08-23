(setq-default custom-file "~/.emacs-custom.el")
(load "~/.emacs-custom.el")

(if (fboundp 'do-applescript)
  (load "~/.emacs.d/darwin.el"))

;; (load-theme 'wheatgrass)
(load-theme 'ample-flat)

(prefer-coding-system       'utf-8)
(set-default-coding-systems 'utf-8)
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

(add-to-list 'after-make-frame-functions (lambda (_) (interactive)
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)
  (set-fontset-font t 'unicode
    (font-spec
      :family "Sarasa Mono Hex"
      :slant 'normal
      :weight 'normal
      :height 130
      :width 'normal))))

(global-auto-composition-mode +1)
;; (pixel-scroll-mode +1)
(show-paren-mode +1)
(column-number-mode +1)
(size-indication-mode +1)
(delete-selection-mode +1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tab-bar-mode -1)

(setq-default
  auth-source-save-behavior nil
  cursor-type 'bar
  minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt)
  prettify-symbols-unprettify-at-point 'right-edge
  visible-cursor nil
  visual-order-cursor-movement t)

(load "~/.emacs.d/bindings.el")
(load "~/.emacs.d/coq.el")
;; (if (package-installed-p 'proof-general) (load "~/.emacs.d/coq.el"))
(load "~/.emacs.d/agda.el")
(load "~/.emacs.d/liga-iosevka.el")

(set-face-attribute 'default nil
  :family "Sarasa Mono Hex"
  :slant 'normal
  :weight 'normal
  :height 130
  :width 'normal)

;; (set-face-attribute 'mode-line nil
;;   :background "gray20"
;;   :foreground "white"
;;   :box nil)

(set-face-attribute 'mode-line-highlight nil
  :box '(:line-width -1 :style nil))

(set-face-attribute 'fringe nil :background 'unspecified)

(set-face-attribute 'variable-pitch nil
  :inherit 'default
  :family 'unspecified)

(set-face-attribute 'fixed-pitch nil
  :inherit 'default
  :family "Sarasa Mono Hex"
  :box nil
  :background 'unspecified
  :foreground 'unspecified)

(set-face-attribute 'fixed-pitch-serif nil
  :inherit 'fixed-pitch
  :family 'unspecified)

(defun set-exec-path-from-shell-PATH ()
  (let ((path-from-shell (shell-command-to-string "$SHELL -i -c 'echo $PATH'")))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

(if window-system (progn
		    (set-exec-path-from-shell-PATH)))

(setq-default
  fcitx-remote-command "fcitx5-remote"
  inhibit-startup-screen t)

(load "~/.emacs.d/telephone-line.el")
