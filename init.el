;; init.el --- Emacs configuration

;; Set OSX function key as Meta
;; INSTALL PACKAGES
;; --------------------------------------
(require 'package)
(add-to-list 'package-archives                                                                                                       
             '("elpy" . "http://jorgenschaefer.github.io/packa..."))  

(add-to-list 'package-archives
       '("melpa" . "https://melpa.org/packages/") t)

;; activate all packages
(package-initialize)
;; fetch the list of packages available
(unless package-archive-contents
  (package-refresh-contents))

;; define list of packages to install

(defvar myPackages
  '(better-defaults
    material-theme
    exec-path-from-shell
    elpy))
   ;;pyenv-mode)) 

;; install all packages in list

(mapc #'(lambda (package)
    (unless (package-installed-p package)
      (package-install package)))
      myPackages)
 
;; Use shell's $PATH

(exec-path-from-shell-copy-env "PATH")

 ;; BASIC CUSTOMIZATION
;; --------------------------------------
(setq inhibit-startup-message t)   ;; hide the startup message
(load-theme 'material t)           ;; load material theme
(global-linum-mode t)              ;; enable line numbers globally
(setq linum-format "%4d \u2502 ")  ;; format line number spacing

;; Allow hash to be entered 

(global-set-key (kbd "M-3") '(lambda () (interactive) (insert "#")))

;; define list of packages to install

(defvar myPackages
  '(better-defaults
    material-theme
    elpy))

(elpy-enable)
;;(pyenv-mode)


(add-hook 'elpy-mode-hook (lambda ()
                            (add-hook 'before-save-hook
                                      'elpy-format-code nil t)))


(setq python-shell-interpreter "ipython"
      python-shell-interpreter-args "-i --simple-prompt");; init.el ends here

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (elpy exec-path-from-shell material-theme better-defaults))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
