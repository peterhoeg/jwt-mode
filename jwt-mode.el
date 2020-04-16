;;; jwt-mode.el --- process jwt tokens              -*- lexical-binding: t; -*-

;; Copyright (C) 2019  Peter Hoeg

;; Author: Peter Hoeg <peter@hoeg.com>
;; Keywords: data
;;
;;; Commentary:
;;
;;

;;; Code:

(defconst jwt-mode-output-buffer "*jwt*"
  "Buffer for output.")

(defvar jwt-mode-cli-command (executable-find "jwt")
  "Default command to run.")

(defvar jwt-mode-cli-decode-arguments "decode"
  "Argument for decoding.")

(defvar jwt-mode-cli-encode-secret nil
  "Secret for creating tokens.")

(defvar jwt-mode-cli-encode-arguments (format "encode --secret '%s'" jwt-cli-encode-secret)
  "Argument for encoding.")

(defvar jwt-mode-show-method 'buffer
  "Argument for encoding.")

(defvar jwt-mode-prefer-posframe nil
  "Show output in posframe.")

(defvar jwt-mode-currently-showing nil
  "Internal variable.")

;; (require 'pos-tip)
(require 'posframe)
(require 's)
(require 'thingatpt)

(defun jwt-mode-construct-command (arg str)
  "Create command to external tool with args ARG and token STR."
  (format "%s %s '%s'" (executable-find jwt-cli-command) arg str))

(defun jwt-mode-run-command (cmd)
  "Execute external tool CMD."
  (call-process-shell-command cmd nil jwt-output-buffer nil)
  (buffer-string))

;; TODO: this has to be improved dramatically
(defun jwt-mode-looks-like-token-p (str)
  "Does STR look like a token."
  (let ((s (s-trim str)))
    (and
     (string-prefix-p "ey" s)
     (> (length s) 20))))

;; TODO: this has to be improved dramatically
(defun jwt-mode-looks-like-json-p (str)
  "Does STR look like JSON."
  (let ((s (s-trim str)))
    (and
     (string-prefix-p "{" s)
     (string-suffix-p "}" s))))

(defun jwt-mode-looks-like-something-we-can-handle-p (str)
  "Does STR look like something we can encode or decode."
  (or (jwt-mode-looks-like-token-p str)
      (jwt-mode-looks-like-json-p str)))

(defun jwt-mode-show-window-dwim (str)
  "Show the JWT window for STR token."
  (interactive)
  (message str))

(defun jwt-mode-show-window (str)
  "Show the JWT window for STR token."
  (message str))

(defun jwt-mode-show-window-pos-tip (str)
  "Show the JWT window for STR token using pos-tip."
  (message str))

(defun jwt-mode-show-window-pos-frame (str)
  "Show the JWT window for STR token in a pos-frame."
  (message str))

(defun jwt-mode-show-window-buffer (str)
  "Show the JWT window for STR token."
  (message str))

;;; autoload
(defun jwt-mode-hide-window ()
  "Hide the JWT window."
  (interactive)

  (setq jwt-mode-currently-showing nil)
  (posframe-delete-frame jwt-mode-output-buffer))

;;; autoload
(defun jwt-mode-dwim (&optional beg end)
  "Try to do the right thing with a selection from BEG to END or the current thing at point."
  (interactive "r")

  (if jwt-mode-currently-showing
      (jwt-mode-hide-window)
    (let ((str (s-trim
                (cond
                 ;; beg end
                 ((jwt-mode-looks-like-something-we-can-handle-p (buffer-substring-no-properties beg end))
                  (buffer-substring-no-properties beg end))
                 ;; region
                 ((and (use-region-p)
                       (buffer-substring-no-properties (region-beginning) (region-end)))
                  (buffer-substring-no-properties (region-beginning) (region-end)))
                 ;; thing at point
                 ;; TODO: we should create a proper handler that detects JSON and tokens
                 ((jwt-mode-looks-like-something-we-can-handle-p (thing-at-point 'word))
                  (thing-at-point 'word))
                 ;; else
                 (t nil)))))
      (if (jwt-mode-looks-like-something-we-can-handle-p str)
          (if (jwt-mode-looks-like-json-p str)
              (jwt-mode-show-window (jwt-mode-encode str))
            (jwt-mode-show-window (jwt-mode-decode str)))
        (message "Unable to find anything that looks like a token or JSON")))))

;;; autoload
(defun jwt-mode-decode (str)
  "Decode the token STR in the currently selected region."
  (jwt-mode-run-command (jwt-mode--construct-command jwt-mode-cli-decode-arguments str)))

;;; autoload
(defun jwt-mode-encode (str)
  "Encode the token STR in the currently selected region."
  (jwt-mode-run-command (jwt-mode--construct-command jwt-mode-cli-encode-arguments str)))


;; eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c

;; eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2lhbS5hcGkuZGV2ZWxvcG1lbnQud2hpc3RsZXIucGVyeHRlY2guaW8iLCJhdWQiOiJodHRwczovL2FwaS5kZXZlbG9wbWVudC53aGlzdGxlci5wZXJ4dGVjaC5pbyIsImlhdCI6MTU3NzA3NzY3Miwic3ViIjoidXJuOndoaXN0bGVyOmlhbTo6MzMzMzMzMzMzOnVzZXIvQWRtaW4iLCJzdWJfY29nbml0byI6InVybjp3aGlzdGxlcjpjb2duaXRvOjozMzMzMzMzMzM6dXNlci8yIn0.-NV0y_f4RqJHvFCcHlrwwsEVUXpvwdjFNwhKY02MG-0

(provide 'jwt-mode)
;;; jwt-mode.el ends here
