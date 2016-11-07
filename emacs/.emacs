;; #### recent files opened ###
;; ############################
(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-items 40)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)



;; #### SPEEDBAR ###
;; #################
;;(speedbar 1)
;;(require 'sr-speedbar)
;;(setq sr-speedbar-width-x 40)
;;(setq sr-speedbar-width-console 40)
;;(setq sr-speedbar-max-width 40)
;;(setq sr-speedbar-right-side nil)

;; #### CSCOPE #####
;; #################
(require 'xcscope)

;; ### EDITTING ####
;; #################
;; tab width
(setq-default tab-width 8)
;; highlight current line
(global-hl-line-mode 1)
;; cc mode
(setq c-default-style '((java-mode . "java")
                        (awk-mode . "awk")
                        (other . "linux")))
;; scrolling - move the cursor
(setq scroll-step 1)
;; scrolling ??
(put 'scroll-left 'disabled nil)
;; line/column numbers in the mode line
(line-number-mode 1)
(column-number-mode 1)

;; ===== Function to delete a line =====
;; First define a variable which will store the previous column position
(defvar previous-column nil "Save the column position")
;; Define the nuke-line function. The line is killed, then the newline
;; character is deleted. The column which the cursor was positioned at is then
;; restored. Because the kill-line function is used, the contents deleted can
;; be later restored by usibackward-delete-char-untabifyng the yank commands.
(defun nuke-line()
  "Kill an entire line, including the trailing newline character"
  (interactive)

  ;; Store the current column position, so it can later be restored for a more
  ;; natural feel to the deletion
  (setq previous-column (current-column))

  ;; Now move to the end of the current line
  (end-of-line)

  ;; Test the length of the line. If it is 0, there is no need for a
  ;; kill-line. All that happens in this case is that the new-line character
  ;; is deleted.
  (if (= (current-column) 0)
    (delete-char 1)

    ;; This is the 'else' clause. The current line being deleted is not zero
    ;; in length. First remove the line by moving to its start and then
    ;; killing, followed by deletion of the newline character, and then
    ;; finally restoration of the column position.
    (progn
      (beginning-of-line)
      (kill-line)
      (delete-char 1)
      (move-to-column previous-column))))
;; Now bind the delete line function to the F8 key
(global-set-key [f8] 'nuke-line)
;; ===== end of function to delete a line =====


;; Key F7 binded to find-dired
(global-set-key [f7] 'find-dired)
;; Key F9 binded to shell-command
(global-set-key [f9] 'shell-command)



;; ### Current Function Name (see Brcm twikis ) ##
(defun c-line-difference (pos1 pos2)
  (let ((lines (count-lines pos1 pos2)))
    (cond ((< pos1 pos2)
      (concat "+" (number-to-string lines)))
     ((> pos1 pos2)
      (concat "-" (number-to-string lines)))
     (t ""))))

(defun c-current-function-name ()
  (save-excursion
    (let ((curpos (point)))
      (forward-paragraph)
      (if (beginning-of-defun)
     (let* ((ident "[a-zA-Z0-9_$:]+")
       (fntype (concat "\\(" ident "[* \t\n]+\\)*"))
       (fmt1 (concat "BCM[A-Z]+FN(\\(" ident "\\))"))
       (fmt2 (concat "\\(" ident "\\)"))
       (re (concat "^" fntype "\\(" fmt1 "\\|" fmt2 "\\)[ \t]*(")))
       (if (re-search-backward re nil t)
      (concat (match-string 3)
         (match-string 4)
         "()"
         (c-line-difference (point) curpos))
         nil))
   nil))))

(add-hook 'c-mode-hook
     '(lambda ()
        (setq mode-line-buffer-identification
         '(:eval (let ((cfn (c-current-function-name)))
              (format "%-20s"
                 (if cfn
                (concat "%b:" cfn)
                   "%b")))))))
;; ### End of Current Function Name ##



;; ### Continuation Line Indenter (see Brcm twikis) ##
; From Bill Stafford for Broadcom HND cstyle rules
; An indentation line should consist of the same indent of the previous
; line using tabs, and any further indentation should use only spaces.

(defun continuation-line-p ()
  (string-match "-cont" (symbol-name (car (car (c-guess-basic-syntax))))))

(defun indent-parent-level ()
  (save-excursion
    ;; move to the parent line
    (while (continuation-line-p)
      (forward-line -1))
    ;; find the indent level of the parent line
    (back-to-indentation)
    (current-column)))

(defun fix-continuation-indentation ()
  (if (not (continuation-line-p))
      nil
    (let ((save-col (current-column))
     (parent-indent (indent-parent-level))
     bol
     cont-indent)
      (beginning-of-line)
      (setq bol (point))
      (back-to-indentation)
      (setq cont-indent (current-column))
      (if (< cont-indent parent-indent)
     (message
      "fix-continuation: Continuation line indent (%d) less than parent's (%d)" 
      cont-indent parent-indent)
   (delete-region bol (point))
   (indent-to parent-indent) ; indent with tabs until the parent indent level
   (insert-char ?\ (- cont-indent parent-indent)) ; follow with spaces
   (move-to-column save-col)))))

(add-hook 'c-special-indent-hook 'fix-continuation-indentation 't)

;; ### end of Continuation Line Indenter ##

;;disable the version control
(setq vc-handled-backends nil) 

;; bash 
;;(setq shell-file-name "bash")

;; save list history (minibuffer)
(savehist-mode 1)

;; #### custom-set-variables #####
;; ##############
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(grep-command "grep -I --exclude-dir=.git --exclude=\"cscope.*\" --exclude=\"*.o\" -nH -e ")
 '(initial-frame-alist (quote ((top . 0) (left . 20) (width . 170) (height . 58))))
 '(speedbar-default-position (quote left))
 '(speedbar-frame-plist (quote (minibuffer nil width 40 border-width 0 internal-border-width 0 unsplittable t default-toolbar-visible-p nil has-modeline-p nil menubar-visible-p nil default-gutter-visible-p nil))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


