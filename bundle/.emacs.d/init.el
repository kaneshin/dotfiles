;; Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
;; Last Change: 04-May-2016.

;; auto-install.el
(add-to-list 'load-path (expand-file-name "~/.emacs.d"))
(require 'auto-install)
(setq auto-install-directory "~/.emacs.d/auto-install/")
(auto-install-update-emacswiki-package-name t)

;; package.el
(require 'package)
;; Add package-archives
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
(package-initialize)

; melpa.el
(require 'melpa)


(global-set-key "\C-h" 'delete-backward-char)

;; ===== Set the highlight current line minor mode ===== 

;; In every buffer, the line which contains the cursor will be fully
;; highlighted

(global-hl-line-mode 1)

;; ========== Place Backup Files in Specific Directory ==========

;; Enable backup files.
(setq make-backup-files t)

;; Save all backup file in this directory.
(setq backup-directory-alist (quote ((".*" . "~/.emacs.d.local/backup/"))))
