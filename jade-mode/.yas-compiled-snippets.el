;;; Compiled snippets and support files for `jade-mode'
;;; Snippet definitions:
;;;
(yas-define-snippets 'jade-mode
                     '(("LICENSE.txt" "The MIT License (MIT)\n\nCopyright (c) 2014 Brian M. Carlson\n\nPermission is hereby granted, free of charge, to any person obtaining a copy\nof this software and associated documentation files (the \"Software\"), to deal\nin the Software without restriction, including without limitation the rights\nto use, copy, modify, merge, publish, distribute, sublicense, and/or sell\ncopies of the Software, and to permit persons to whom the Software is\nfurnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in\nall copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\nIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\nFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\nAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\nLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\nOUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\nTHE SOFTWARE.\n" "LICENSE.txt" nil nil nil nil nil nil)
                       ("README.md" "# sws-mode\n\n## major mode for jade-mode and stylus-mode\n\n__S__ignificant __W__hitespace __M__ode.  Because Jade and Stylus are both 'significant white space' languages, sws-mode can be used to edit both types of files\n\nLines can be indented or un-indented (is that a word?) with tab, shift-tab respectively.  Indentation will look at the proceeding line and not indent more than 1 level of nesting below it.\n\n    html\n      body\n        #container\n        .content\n      ^\n      |----cursor anywhere on this line except at beginning of text, press tab or S-tab\n\n    html\n      body\n        #container\n        .content\n        ^\n        |---- cursor moves to beginning of text...once cursor is at beginning of text, press tab\n\n    html\n      body\n        #container\n          .content\n          ^\n          |---- now line is maximum indented, press tab again\n\n    html\n      body\n        #container\n    .content\n    ^\n    |---- line moves to minimum indentation level (no indentation)\n\nRegions can be indentend in a similar way; however, this is still buggy...\n\nSince jade and stylus nesting is somewhat related to sexp layout I hope to have sexp related selection & manipulation working in the future.  See `jade-highlight-sexp` for an example\n\n## key bindings\n\n  - [tab] if region is active, do 'smart indent' on region.  otherwise, move cursor to beginning of line text.  If cursor already at beginning of line text, do 'smart indent' on line.\n  - [shift-tab] if region is active, do 'smart dedent' on region.  otherwise, move cursor to beginning of line text.  If cursor already at beginning of line text, do 'smart dedent' on line.\n\n\n### jade-mode\n\nEmacs major mode for [jade template](http://github.com/visionmedia/jade) highlighting.  This mode extends sws-mode to provide some rudimentary syntax highlighting.\n\nStill in very early stages.  Some simple highlighting of tags, ids, and classes works; however, it highlights incorrectly into the javascript code and plain text code as well.\n\n\nI would like to get the highlighting working better.  Also note javascript highlighting with either js2-mode or espresso-mode should be possible...I'm a major major-mode writing noob so it'll take a while.\n\n### stylus-mode\nI'm not sure yet how to highlight .styl files, so for now, just use sws-mode when editing stylus mode.\n\n## Installation instructions\n\nCopy the jade-mode.el and sws-mode.el to some directory on your computer.  I put mine under `~/code/jade-mode` and sym-link the jade-mode folder into `~/.emacs.d/vendor/`.  You can just as easily put the folder itself under '~/.emacs.d/vendor/`\n\nAdd the following lines to any of your initialization files\n\n    (add-to-list 'load-path \"~/.emacs.d/vendor/jade-mode\")\n    (require 'sws-mode)\n    (require 'jade-mode)    \n    (add-to-list 'auto-mode-alist '(\"\\\\.styl$\" . sws-mode))\n    (add-to-list 'auto-mode-alist '(\"\\\\.jade$\" . jade-mode))\n\n### Flymake support\n\nif you want to add flymake support for jade files:\n\n    (defun flymake-jade-init ()\n      (let* ((temp-file (flymake-init-create-temp-buffer-copy\n                     'flymake-create-temp-intemp))\n         (local-file (file-relative-name\n                      temp-file\n                      (file-name-directory buffer-file-name)))\n         (arglist (list local-file)))\n        (list \"jade\" arglist)))\n    (setq flymake-err-line-patterns\n           (cons '(\"\\\\(.*\\\\): \\\\(.+\\\\):\\\\([[:digit:]]+\\\\)$\"\n                  2 3 nil 1)\n                flymake-err-line-patterns))\n    (add-to-list 'flymake-allowed-file-name-masks\n             '(\"\\\\.jade\\\\'\" flymake-jade-init))\n" "README.md" nil nil nil nil nil nil)
                       ("example.jade" "!!!\nhtml(lang=\"en\")\n  head\n    title My page\n  body.bp\n    #container\n      #header\n        h1.page-title= My.awesome. page #is awesome#\n      #nav\n        ul#nav_list something sweet\n          li\n      #content\n        - if (youAreUsingJade)\n          p You are amazing\n        - else\n          p Get on it!\n          form\n            input(type: \"text\", name='user[name]', readonly: true, disabled)\n      #footer\n        #copywrite-text= locals\n        \n        \n\n        \n\n        \n        \n" "example.jade" nil nil nil nil nil nil)
                       ("jade-mode.el" ";;; jade-mode.el --- Major mode for editing .jade files\n;;;\n;;; URL: https://github.com/brianc/jade-mode\n;;; Author: Brian M. Carlson and other contributors\n;;; Package-Requires: ((sws-mode \"0\"))\n;;;\n;;; copied from http://xahlee.org/emacs/elisp_syntax_coloring.html\n(require 'font-lock)\n(require 'sws-mode)\n\n(defun jade-debug (string &rest args)\n  \"Prints a debug message\"\n  (apply 'message (append (list string) args)))\n\n(defmacro jade-line-as-string ()\n  \"Returns the current line as a string.\"\n  `(buffer-substring (point-at-bol) (point-at-eol)))\n\n\n(defun jade-empty-line-p ()\n  \"If line is empty or not.\"\n  (= (point-at-eol) (point-at-bol)))\n\n(defun jade-blank-line-p ()\n  \"If line contains only spaces.\"\n  (string-match-p \"^[ ]*$\" (jade-line-as-string)))\n\n;; command to comment/uncomment text\n(defun jade-comment-dwim (arg)\n  \"Comment or uncomment current line or region in a smart way.\nFor detail, see `comment-dwim'.\"\n  (interactive \"*P\")\n  (require 'newcomment)\n  (let (\n        (comment-start \"//\") (comment-end \"\")\n        )\n    (comment-dwim arg)))\n\n(defconst jade-keywords\n  (eval-when-compile\n    (regexp-opt\n     '(\"if\" \"else\" \"for\" \"in\" \"each\" \"case\" \"when\" \"default\" \"block\" \"extends\"\n       \"block append\" \"block prepend\" \"append\" \"prepend\"\n       \"include\" \"yield\" \"mixin\") 'words))\n  \"Jade keywords.\")\n\n(defvar jade-font-lock-keywords\n  `((,\"!!!\\\\|doctype\\\\( ?[A-Za-z0-9\\-\\_]*\\\\)?\" 0 font-lock-comment-face) ;; doctype\n    (,jade-keywords . font-lock-keyword-face) ;; keywords\n    (,\"#\\\\(\\\\w\\\\|_\\\\|-\\\\)*\" . font-lock-variable-name-face) ;; id\n    (,\"\\\\(?:^[ {2,}]*\\\\(?:[a-z0-9_:\\\\-]*\\\\)\\\\)?\\\\(#[A-Za-z0-9\\-\\_]*[^ ]\\\\)\" 1 font-lock-variable-name-face) ;; id\n    (,\"\\\\(?:^[ {2,}]*\\\\(?:[a-z0-9_:\\\\-]*\\\\)\\\\)?\\\\(\\\\.[A-Za-z0-9\\-\\_]*\\\\)\" 1 font-lock-type-face) ;; class name\n    (,\"^[ {2,}]*[a-z0-9_:\\\\-]*\" 0 font-lock-function-name-face))) ;; tag name\n\n;; syntax table\n(defvar jade-syntax-table\n  (let ((syn-table (make-syntax-table)))\n    (modify-syntax-entry ?\\/ \". 12b\" syn-table)\n    (modify-syntax-entry ?\\n \"> b\" syn-table)\n    (modify-syntax-entry ?' \"\\\"\" syn-table)\n    syn-table)\n  \"Syntax table for `jade-mode'.\")\n\n(defun jade-region-for-sexp ()\n  \"Selects the current sexp as the region\"\n  (interactive)\n  (beginning-of-line)\n  (let ((ci (current-indentation)))\n    (push-mark nil nil t)\n    (while (> (jade-next-line-indent) ci)\n      (next-line)\n      (end-of-line))))\n\n(defvar jade-mode-map (make-sparse-keymap))\n;;defer to sws-mode\n;;(define-key jade-mode-map [S-tab] 'jade-unindent-line)\n\n;; mode declaration\n;;;###autoload\n(define-derived-mode jade-mode sws-mode\n  \"Jade\"\n  \"Major mode for editing jade node.js templates\"\n  :syntax-table jade-syntax-table\n\n  (setq tab-width 4)\n\n  (setq mode-name \"Jade\")\n  (setq major-mode 'jade-mode)\n\n  ;; comment syntax\n  (set (make-local-variable 'comment-start) \"// \")\n\n  ;; default tab width\n  (setq sws-tab-width 4)\n  (make-local-variable 'indent-line-function)\n  (setq indent-line-function 'sws-indent-line)\n  (make-local-variable 'indent-region-function)\n\n  (setq indent-region-function 'sws-indent-region)\n\n  (setq indent-tabs-mode nil)\n\n  ;; keymap\n  (use-local-map jade-mode-map)\n\n  ;; modify the keymap\n  (define-key jade-mode-map [remap comment-dwim] 'jade-comment-dwim)\n\n  ;; highlight syntax\n  (setq font-lock-defaults '(jade-font-lock-keywords)))\n\n\n;;;###autoload\n(add-to-list 'auto-mode-alist '(\"\\\\.jade$\" . jade-mode))\n\n(provide 'jade-mode)\n;;; jade-mode.el ends here\n" "jade-mode.el" nil nil nil nil nil nil)
                       ("stylus-mode.el" ";;; stylus-mode.el --- Major mode for editing .jade files\n;;;\n;;; URL: https://github.com/brianc/jade-mode\n;;; Author: Brian M. Carlson and other contributors\n;;; Package-Requires: ((sws-mode \"0\"))\n;;;\n;;; copied from http://xahlee.org/emacs/elisp_syntax_coloring.html\n(require 'font-lock)\n(require 'sws-mode)\n\n(defun stylus-debug (string &rest args)\n  \"Prints a debug message\"\n  (apply 'message (append (list string) args)))\n\n(defmacro stylus-line-as-string ()\n  \"Returns the current line as a string.\"\n  `(buffer-substring (point-at-bol) (point-at-eol)))\n\n\n(defun stylus-empty-line-p ()\n  \"If line is empty or not.\"\n  (= (point-at-eol) (point-at-bol)))\n\n(defun stylus-blank-line-p ()\n  \"If line contains only spaces.\"\n  (string-match-p \"^[ ]*$\" (stylus-line-as-string)))\n\n(defconst stylus-colours\n  (eval-when-compile\n    (regexp-opt\n     '(\"black\" \"silver\" \"gray\" \"white\" \"maroon\" \"red\"\n       \"purple\" \"fuchsia\" \"green\" \"lime\" \"olive\" \"yellow\" \"navy\"\n       \"blue\" \"teal\" \"aqua\")))\n  \"Stylus keywords.\")\n\n(defconst stylus-keywords\n  (eval-when-compile\n    (regexp-opt\n     '(\"return\" \"if\" \"else\" \"unless\" \"for\" \"in\" \"true\" \"false\")))\n  \"Stylus keywords.\")\n\n(defvar stylus-font-lock-keywords\n  `(\n    (,\"^[ {2,}]+[a-z0-9_:\\\\-]+[ ]\" 0 font-lock-variable-name-face)\n    (,\"\\\\(::?\\\\(root\\\\|nth-child\\\\|nth-last-child\\\\|nth-of-type\\\\|nth-last-of-type\\\\|first-child\\\\|last-child\\\\|first-of-type\\\\|last-of-type\\\\|only-child\\\\|only-of-type\\\\|empty\\\\|link\\\\|visited\\\\|active\\\\|hover\\\\|focus\\\\|target\\\\|lang\\\\|enabled\\\\|disabled\\\\|checked\\\\|not\\\\)\\\\)*\" . font-lock-type-face) ;; pseudoSelectors\n    (,(concat \"[^_$]?\\\\<\\\\(\" stylus-colours \"\\\\)\\\\>[^_]?\")\n     0 font-lock-constant-face)\n    (,(concat \"[^_$]?\\\\<\\\\(\" stylus-keywords \"\\\\)\\\\>[^_]?\")\n     0 font-lock-keyword-face)\n    (,\"#\\\\w[a-zA-Z0-9\\\\-]+\" 0 font-lock-keyword-face) ; id selectors (also colors...)\n    (,\"\\\\([.0-9]+:?\\\\(em\\\\|ex\\\\|px\\\\|mm\\\\|cm\\\\|in\\\\|pt\\\\|pc\\\\|deg\\\\|rad\\\\|grad\\\\|ms\\\\|s\\\\|Hz\\\\|kHz\\\\|rem\\\\|%\\\\)\\\\b\\\\)\" 0 font-lock-constant-face)\n    (,\"\\\\b[0-9]+\\\\b\" 0 font-lock-constant-face)\n    (,\"\\\\.\\\\w[a-zA-Z0-9\\\\-]+\" 0 font-lock-type-face) ; class names\n    (,\"$\\\\w+\" 0 font-lock-variable-name-face)\n    (,\"@\\\\w[a-zA-Z0-9\\\\-]+\" 0 font-lock-preprocessor-face) ; directives and backreferences\n    ))\n\n(defvar stylus-syntax-table\n  (let ((syntable (make-syntax-table)))\n    (modify-syntax-entry ?\\/ \". 124b\" syntable)\n    (modify-syntax-entry ?* \". 23\" syntable)\n    (modify-syntax-entry ?\\n \"> b\" syntable)\n    (modify-syntax-entry ?' \"\\\"\" syntable)\n    syntable)\n  \"Syntax table for `stylus-mode'.\")\n\n(defun stylus-region-for-sexp ()\n  \"Selects the current sexp as the region\"\n  (interactive)\n  (beginning-of-line)\n  (let ((ci (current-indentation)))\n    (push-mark nil nil t)\n    (while (> (stylus-next-line-indent) ci)\n      (next-line)\n      (end-of-line))))\n\n(defvar stylus-mode-map (make-sparse-keymap))\n;;defer to sws-mode\n;;(define-key stylus-mode-map [S-tab] 'stylus-unindent-line)\n\n;; mode declaration\n;;;###autoload\n(define-derived-mode stylus-mode sws-mode\n  \"Stylus\"\n  \"Major mode for editing stylus node.js templates\"\n  (setq tab-width 2)\n\n  (setq mode-name \"Stylus\")\n  (setq major-mode 'stylus-mode)\n\n  ;; syntax table\n  (set-syntax-table stylus-syntax-table)\n\n  ;; highlight syntax\n  (setq font-lock-defaults '(stylus-font-lock-keywords))\n\n  ;; comments\n  (set (make-local-variable 'comment-start) \"//\")\n  (set (make-local-variable 'comment-end) \"\")\n\n  ;; default tab width\n  (setq sws-tab-width 2)\n  (make-local-variable 'indent-line-function)\n  (setq indent-line-function 'sws-indent-line)\n  (make-local-variable 'indent-region-function)\n\n  (setq indent-region-function 'sws-indent-region)\n\n  ;; keymap\n  (use-local-map stylus-mode-map))\n\n;;;###autoload\n(add-to-list 'auto-mode-alist '(\"\\\\.styl$\" . stylus-mode))\n\n(provide 'stylus-mode)\n;;; stylus-mode.el ends here\n" "stylus-mode.el" nil nil nil nil nil nil)
                       ("sws-mode.el" ";;; sws-mode.el --- (S)ignificant (W)hite(S)pace mode\n;;;\n;;; URL: https://github.com/brianc/jade-mode\n;;; Author: Brian M. Carlson and other contributors\n;;;\n(require 'font-lock)\n\n(defvar sws-tab-width 2)\n\n(defmacro sws-line-as-string ()\n  \"Returns the current line as a string.\"\n  `(buffer-substring (point-at-bol) (point-at-eol)))\n\n(defun sws-previous-indentation ()\n  \"Gets indentation of previous line\"\n  (save-excursion\n    (forward-line -1)\n    (if (bobp) 0\n      (progn\n        (while (and (looking-at \"^[ \\t]*$\") (not (bobp))) (forward-line -1))\n        (current-indentation)))))\n\n(defun sws-max-indent ()\n  \"Calculates max indentation\"\n  (+ (sws-previous-indentation) sws-tab-width))\n\n(defun sws-empty-line-p ()\n  \"If line is completely empty\"\n  (= (point-at-bol) (point-at-eol)))\n\n(defun sws-point-to-bot ()\n  \"Moves point to beginning of text\"\n  (beginning-of-line-text))\n\n(defun sws-do-indent-line ()\n  \"Performs line indentation\"\n  ;;if we are not tabbed out past max indent\n  (if (sws-empty-line-p)\n      (indent-to (sws-max-indent))\n    (if (< (current-indentation) (sws-max-indent))\n        (indent-to (+ (current-indentation) sws-tab-width))\n      ;; if at max indent move text to beginning of line\n      (progn\n        (beginning-of-line)\n        (delete-horizontal-space)))))\n\n(defun sws-indent-line ()\n  \"Indents current line\"\n  (interactive)\n  (if (eq this-command 'indent-for-tab-command)\n    (if mark-active\n        (sws-indent-region (region-beginning) (region-end))\n      (if (sws-at-bot-p)\n          (sws-do-indent-line)\n        (sws-point-to-bot)))\n    (indent-to (sws-previous-indentation))))\n\n(defun sws-at-bol-p ()\n  \"If point is at beginning of line\"\n  (interactive)\n  (= (point) (point-at-bol)))\n\n(defun sws-at-bot-p ()\n  \"If point is at beginning of text\"\n  (= (point) (+ (current-indentation) (point-at-bol))))\n\n(defun sws-print-line-number ()\n  \"Prints line number\"\n  (sws-print-num (point)))\n\n(defun sws-print-num (arg)\n  \"Prints line number\"\n  (message (number-to-string arg)))\n\n(defun sws-indent-to (num)\n  \"Force indentation to level including those below current level\"\n  (save-excursion\n    (beginning-of-line)\n    (delete-horizontal-space)\n    (indent-to num)))\n\n(defun sws-move-region (begin end prog)\n  \"Moves left is dir is null, otherwise right. prog is '+ or '-\"\n  (save-excursion\n    (let (first-indent indent-diff)\n      (goto-char begin)\n      (setq first-indent (current-indentation))\n      (sws-indent-to\n       (funcall prog first-indent sws-tab-width))\n      (setq indent-diff (- (current-indentation) first-indent))\n      ;; move other lines based on movement of first line\n      (while (< (point) end)\n        (forward-line 1)\n        (if (< (point) end)\n            (sws-indent-to (+ (current-indentation) indent-diff)))))))\n\n(defun sws-indent-region (begin end)\n  \"Indents the selected region\"\n  (interactive)\n  (sws-move-region begin end '+))\n\n\n(defun sws-dendent-line ()\n  \"De-indents current line\"\n  (interactive)\n  (if mark-active\n      (sws-move-region (region-beginning) (region-end) '-)\n    (if (sws-at-bol-p)\n        (progn\n          (message \"at mother fucking bol\")\n          (delete-horizontal-space)\n          (indent-to (sws-max-indent)))\n      (let ((ci (current-indentation)))\n        (beginning-of-line)\n        (delete-horizontal-space)\n        (indent-to (- ci sws-tab-width))))))\n\n(defvar sws-mode-map (make-sparse-keymap))\n(define-key sws-mode-map [S-tab] 'sws-dendent-line)\n(define-key sws-mode-map [backtab] 'sws-dendent-line)\n\n;;;###autoload\n(define-derived-mode sws-mode fundamental-mode\n  \"sws\"\n  \"Major mode for editing significant whitespace files\"\n  (kill-all-local-variables)\n\n  ;; default tab width\n  (setq sws-tab-width 2)\n  (make-local-variable 'indent-line-function)\n  (setq indent-line-function 'sws-indent-line)\n  (make-local-variable 'indent-region-function)\n\n  (setq indent-region-function 'sws-indent-region)\n\n  ;; TODO needed?\n  (setq indent-tabs-mode nil)\n\n  ;; keymap\n  (use-local-map sws-mode-map)\n  (setq major-mode 'sws-mode))\n\n(provide 'sws-mode)\n;;; sws-mode.el ends here\n" "sws-mode.el" nil nil nil nil nil nil)))


;;; Do not edit! File generated at Tue May 12 12:12:42 2015