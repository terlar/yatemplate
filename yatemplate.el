;;; yatemplate.el --- File templates with yasnippet

;; Copyright (C) 2015  Wieland Hoffmann <themineo+yatemplate@gmail.com>

;; Author: Wieland Hoffmann <themineo+yatemplate@gmail.com>
;; URL: https://github.com/mineo/yatemplate
;; Version: 1.0
;; Package-Requires: ((yasnippet "0.8.1"))
;; Keywords: files, convenience

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package bridges the gap betwen yasnippet and auto-insert-mode. By
;; populating auto-insert-alist with filenames and automatically expanding their
;; content after insertion by auto-insert-mode, it's an easy way to create
;; dynamic file templates. Simply call `yatemplate-fill-alist' somewhere in your
;; Emacs initialization file to populate `auto-insert-alist' with filenames from
;; `yatemplate-dir'.

;; Each filename will be turned into a new element to `push' onto
;; `auto-insert-alist'. To guarantee a particular order, filenames must contain
;; one colon (":"). After collecting all the filenames in `yatemplate-dir',
;; their names will be sorted with `string<', then split on the colon. The first
;; substring will be discarded, which means it can be used to establish an
;; ordering. The second substring will be used as a regexp as the CONDITION of
;; the element to push onto `auto-insert-alist'. The ACTION will be a vector of
;; actions that first insert the content of the template file and then expand
;; the content of the buffer with `yatemplate-expand-yas-buffer'.

;; This means that if `yatemplate-dir' looks like this:

;; .emacs.d/templates
;; ├── 00:test_.*.py
;; └── 01:.*.py

;; `yatemplate-fill-alist' will first `push' (".*.py" . ACTION) onto
;; `auto-insert-alist' and then ("test_.*.py" . ACTION).

;; Of course, you will need to enable `auto-insert-mode' to have the snippet
;; inserted and expanded into new files.

;;; Code:

(require 'autoinsert)
(require 'yasnippet)

(defgroup yatemplate
  nil
  "Customization group for yatemplate."
  :group 'files
  :group 'convenience)

(defcustom yatemplate-dir
  (locate-user-emacs-file "templates")
  "The directory containing file templates."
  :group 'yatemplate)

(defun yatemplate-expand-yas-buffer ()
  "Expand the whole buffer with `yas-expand-snippet'."
  (yas-expand-snippet (buffer-string) (point-min) (point-max)))

(defun yatemplate-sorted-files-in-dir ()
  "Return a sorted list of files in the template directory."
  (sort (file-expand-wildcards (concat yatemplate-dir "**/*")) 'string<))

(defun yatemplate-filename-split-regex (FILENAME)
  "Split the regular expression from FILENAME and return it."
  (nth 1 (split-string FILENAME ":")))

;;;###autoload
(defun yatemplate-fill-alist ()
  "Fill `auto-insert-alist'."
  (dolist (filename (reverse (yatemplate-sorted-files-in-dir)) nil)
    (let ((file-regex (yatemplate-filename-split-regex filename)))
      (push `(,file-regex . [,filename yatemplate-expand-yas-buffer]) auto-insert-alist))))

(provide 'yatemplate)
;;; yatemplate.el ends here
