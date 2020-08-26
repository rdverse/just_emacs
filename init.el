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





;; Latex Customizations

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; setting up latex mode
;; Forward/inverse search with evince using D-bus.
;; Installation:
;; M-x package-install RET auctex RET
(add-hook 'LaTeX-mode-hook 'TeX-PDF-mode)
(add-hook 'LaTeX-mode-hook 'TeX-source-correlate-mode)
(setq TeX-source-correlate-method 'synctex)

(if (require 'dbus "dbus" t)
    (progn
      ;; universal time, need by evince
      (defun utime ()
	(let ((high (nth 0 (current-time)))
	      (low (nth 1 (current-time))))
	  (+ (* high (lsh 1 16) ) low)))

      ;; Forward search.
      ;; Adapted from http://dud.inf.tu-dresden.de/~ben/evince_synctex.tar.gz
      (defun auctex-evince-forward-sync (pdffile texfile line)
	(let ((dbus-name
	       (dbus-call-method :session
				 "org.gnome.evince.Daemon"  ; service
				 "/org/gnome/evince/Daemon" ; path
				 "org.gnome.evince.Daemon"  ; interface
				 "FindDocument"
				 (concat "file://" pdffile)
				 t     ; Open a new window if the file is not opened.
				 )))
	  (dbus-call-method :session
			    dbus-name
			    "/org/gnome/evince/Window/0"
			    "org.gnome.evince.Window"
			    "SyncView"
			    texfile
			    (list :struct :int32 line :int32 1)
			    (utime))))

      (defun auctex-evince-view ()
	(let ((pdf (file-truename (concat default-directory
					  (TeX-master-file (TeX-output-extension)))))
	      (tex (buffer-file-name))
	      (line (line-number-at-pos)))
	  (auctex-evince-forward-sync pdf tex line)))

      ;; New view entry: Evince via D-bus.
      (setq TeX-view-program-list '())
      (add-to-list 'TeX-view-program-list
		   '("EvinceDbus" auctex-evince-view))

      ;; Prepend Evince via D-bus to program selection list
      ;; overriding other settings for PDF viewing.
      (setq TeX-view-program-selection '())
      (add-to-list 'TeX-view-program-selection
		   '(output-pdf "EvinceDbus"))

      ;; Inverse search.
      ;; Adapted from: http://www.mail-archive.com/auctex@gnu.org/msg04175.html
      (defun auctex-evince-inverse-sync (file linecol timestamp)
	(let ((buf (get-file-buffer (substring file 7)))
	      (line (car linecol))
	      (col (cadr linecol)))
	  (if (null buf)
	      (message "Sorry, %s is not opened..." file)
	    (switch-to-buffer buf)
	    (goto-line (car linecol))
	    (unless (= col -1)
	      (move-to-column col)))))

      (dbus-register-signal
       :session nil "/org/gnome/evince/Window/0"
       "org.gnome.evince.Window" "SyncSource"
       'auctex-evince-inverse-sync)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;; Auto complete yasnippet


;; yasnippet code 'optional', before auto-complete
(require 'yasnippet)
(yas-global-mode 1)

;; auto-complete setup, sequence is important
(require 'auto-complete)
(add-to-list 'ac-modes 'latex-mode) ; beware of using 'LaTeX-mode instead
(require 'ac-math) ; package should be installed first 
(defun my-ac-latex-mode () ; add ac-sources for latex
   (setq ac-sources
         (append '(ac-source-math-unicode
           ac-source-math-latex
           ac-source-latex-commands)
                 ac-sources)))
(add-hook 'LaTeX-mode-hook 'my-ac-latex-mode)
(setq ac-math-unicode-in-math-p t)
(ac-flyspell-workaround) ; fixes a known bug of delay due to flyspell (if it is there)
(add-to-list 'ac-modes 'org-mode) ; auto-complete for org-mode (optional)

(require 'auto-complete-config) ; should be after add-to-list 'ac-modes and hooks

(add-to-list 'ac-dictionary-directories "~/.emacs.d/.dict") ; make sure this folder exists
(add-to-list 'ac-user-dictionary-files "~/.emacs.d/.dict/custom-dict.txt") ; put any name to your `.txt` file  
(ac-config-default)
(setq ac-auto-start nil)            ; if t starts ac at startup automatically
(setq ac-auto-show-menu t)
(ac-set-trigger-key "TAB")
(ac-set-trigger-key "<tab>")  
(global-auto-complete-mode t)





