(require 'company-coq)

(setq-default coq-symbols-alist '(lambda ()
  (setq-local prettify-symbols-alist
        '(("Qed." . ?■) ("Defined." . ?◆)
          ("Gamma" . ?Γ) ("Delta" . ?Δ)
          ("Theta" . ?Θ) ("Lambda" . ?Λ) ("Xi" . ?Ξ)
          ("Pi" . ?Π) ("Sigma" . ?Σ)
          ("Upsilon" . ?Υ) ("Phi" . ?Φ)
          ("Psi" . ?Ψ) ("Omega" . ?Ω)
          ("alpha" . ?α) ("beta" . ?β) ("gamma" . ?γ)
          ("delta" . ?δ) ("epsilon" . ?ε) ("zeta" . ?ζ)
          ("eta" . ?η) ("theta" . ?θ) ("iota" . ?ι)
          ("kappa" . ?κ) ("mu" . ?μ)
          ("nu" . ?ν) ("xi" . ?ξ)
          ("pi" . ?π) ("rho" . ?ρ) ("sigma" . ?σ)
          ("tau" . ?τ) ("upsilon" . ?υ) ("phi" . ?φ)
          ("chi" . ?χ) ("psi" . ?ψ) ("omega" . ?ω)
          ("\\in" . ?∈) ("|-" . ?⊢)
          ("False" . ?⊥) ("fun" . ?λ) ("forall" . ?∀) ("exists" . ?∃)))))

(setq-default
  proof-general-name nil
  company-coq-prettify-symbols-alist '()
  company-coq-disabled-features '(smart-subscripts spinner))

(setq-default company-coq--rooster-char-displayable nil)

(require 'coq-db)
(require 'proof-faces)
(set-face-attribute 'coq-cheat-face nil
  :foreground "red" :weight 'bold :box nil :background 'unspecified)

(set-face-attribute 'coq-solve-tactics-face nil
  :foreground 'unspecified :inherit 'proof-tactics-name-face)

(add-hook 'coq-mode-hook #'company-coq-mode)
(add-hook 'coq-mode-hook coq-symbols-alist)
(add-hook 'coq-goals-mode-hook coq-symbols-alist)
(add-hook 'coq-response-mode-hook coq-symbols-alist)
(add-hook 'coq-shell-mode-hook coq-symbols-alist)
