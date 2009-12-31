(require 'cl)

(defun replace-in-files (matches files)
  (save-excursion
    (mapc (lambda (file)
	    (switch-to-buffer (or (find-buffer-visiting file) (find-file file)))
	    (mapc (lambda (x)
		    (beginning-of-buffer)
		    (let ((case-fold-search nil))
		      (print x)
		      (while (search-forward-regexp (car x) nil t)
			(replace-match (cdr x) nil t)))
		    (save-buffer)
		    )
		  matches))
	  files)))

(defun ecl-load-symbols ()
  (interactive)
  (beginning-of-buffer)
  (while (re-search-forward ";;; Address = \\([0-9a-f]*\\)" nil t)
    (let ((address (buffer-substring (match-beginning 1)
				     (match-end 1))))
      (re-search-backward ";;; Loading \\(/.*\.o\\)$")
      (let ((file (buffer-substring (match-beginning 1)
				    (match-end 1))))
	(print file) (print address)
	(save-excursion
	  (gud-call (format "add-symbol-file %s 0x%s" file address))))
      (next-line 2))))

(defvar ecl-search-string)

(defun query-replace-ecl (from-string to-string &optional delimited start end)
  (interactive (query-replace-read-args "Query replace" nil))
  (setq ecl-search-string from-string)
  (let ((remaining (member (buffer-file-name (current-buffer)) ecl-files)))
    (dolist (i (or remaining ecl-files))
      (let ((b (find-buffer-visiting i)))
	(unless (equal b (current-buffer))
	  (switch-to-buffer b)
	  (beginning-of-buffer)))
      (perform-replace from-string to-string t nil delimited nil nil
		       start end))))

(defun search-ecl (string)
  (interactive "sString: ")
  (setq ecl-search-string string)
  (let ((remaining (member (buffer-file-name (current-buffer)) ecl-files)))
    (dolist (i (or remaining ecl-files))
      (let ((b (find-buffer-visiting i)))
	(unless (equal b (current-buffer))
	  (print b)
	  (switch-to-buffer b)
	  (beginning-of-buffer)))
      (print '*)
      (setq case-fold-search t)
      (if (search-forward string nil t)
	  (return)))))

(defun search-next-ecl ()
  (interactive)
  (search-ecl ecl-search-string))

(defun back-to-emacs ()
  (interactive)
  (switch-to-buffer "emacs.el"))

(defun next-ecl ()
  (interactive)
  (let ((remaining (member (buffer-file-name (current-buffer)) ecl-files)))
    (when (cdr remaining)
      (switch-to-buffer (find-buffer-visiting (cadr remaining))))))

(global-set-key [?\M-p ?\C-i] 'back-to-emacs)
(global-set-key [?\M-p ?\C-s] 'search-ecl)
(global-set-key [?\M-p ?\C-n] 'search-next-ecl)
(global-set-key [?\M-p ?\C-m] 'next-ecl)
(global-set-key [?\M-p ?\C-p] 'ecl-load-symbols)

(setq auto-mode-alist (acons "\\.d\\'" 'c-mode auto-mode-alist))

(setq ecl-files
      (mapcar (lambda (x)
		(set-buffer "emacs.el")
		(concat (subseq (buffer-file-name (current-buffer)) 0 -13) x))
	      '(
"h/object.h"
"h/eval.h"
"h/external.h"
"h/stacks.h"
"c/character.d"
"c/gfun.d"
"c/num_comp.d"
"c/string.d"
"c/hash.d"
"c/num_log.d"
"c/structure.d"
"c/num_pred.d"
"c/symbol.d"
"c/cmpaux.d"
"c/instance.d"
"c/num_rand.d"
"c/all_symbols.d"
"c/symbols_list.h"
"c/num_sfun.d"
"c/tcp.d"
"c/alloc.d"
"c/number.d"
"c/time.d"
"c/alloc_2.d"
"c/dosdummy.d"
"c/package.d"
"c/apply.d"
"c/dostimes.d"
"c/list.d"
"c/pathname.d"
"c/array.d"
"c/dpp.c"
"c/load.d"
"c/predicate.d"
"c/typespec.d"
"c/assignment.d"
"c/earith.d"
"c/print.d"
;"c/unify.d"
"c/backq.d"
"c/error.d"
"c/macros.d"
"c/unixfsys.d"
"c/big.d"
"c/eval.d"
"c/main.d"
"c/unixint.d"
"c/file.d"
"c/mapfun.d"
"c/read.d"
"c/unixsys.d"
"c/format.d"
"c/reference.d"
"c/num_arith.d"
"c/sequence.d"
"c/cfun.d"
"c/gbc.d"
"c/num_co.d"
"c/stacks.d"
"c/interpreter.d"
"c/compiler.d"
"c/disassembler.d"
"c/multival.d"
"c/threads.d"
"c/ffi.d"
"lsp/arraylib.lsp"
"lsp/assert.lsp"
"lsp/autoload.lsp"
"lsp/cmpinit.lsp"
"lsp/cmuutil.lsp"
"lsp/format.lsp"
"lsp/defmacro.lsp"
"lsp/defpackage.lsp"
"lsp/defstruct.lsp"
"lsp/describe.lsp"
"lsp/evalmacros.lsp"
"lsp/export.lsp"
"lsp/helpfile.lsp"
"lsp/iolib.lsp"
"lsp/listlib.lsp"
"lsp/loop.lsp"
"lsp/loop2.lsp"
"lsp/mislib.lsp"
"lsp/module.lsp"
"lsp/numlib.lsp"
"lsp/packlib.lsp"
"lsp/pprint.lsp"
"lsp/predlib.lsp"
"lsp/proclaim.lsp"
"lsp/seq.lsp"
"lsp/seqlib.lsp"
"lsp/setf.lsp"
"lsp/mp.lsp"
"lsp/top.lsp"
"lsp/trace.lsp"
"lsp/util.lsp"
"lsp/ffi.lsp"
"clos/boot.lsp"
"clos/builtin.lsp"
"clos/change.lsp"
"clos/cmpinit.lsp"
"clos/combin.lsp"
"clos/defclass.lsp"
"clos/fixup.lsp"
"clos/generic.lsp"
"clos/init.lsp"
"clos/inspect.lsp"
"clos/kernel.lsp"
"clos/macros.lsp"
"clos/method.lsp"
"clos/precomp.lsp"
"clos/print.lsp"
"clos/slot.lsp"
"clos/standard.lsp"
"clos/stdmethod.lsp"
"clos/walk.lsp"
"clos/conditions.lsp"
"new-cmp/cmparray.lsp"
"new-cmp/cmpblock.lsp"
"new-cmp/cmpc-bind.lsp"
"new-cmp/cmpc-cbk.lsp"
"new-cmp/cmpc-data.lsp"
"new-cmp/cmpc-ffi.lsp"
"new-cmp/cmpc-inline.lsp"
"new-cmp/cmpc-loc.lsp"
"new-cmp/cmpc-ops.lsp"
"new-cmp/cmpc-pass.lsp"
"new-cmp/cmpc-set.lsp"
"new-cmp/cmpc-tables.lsp"
"new-cmp/cmpc-top.lsp"
"new-cmp/cmpc-wt.lsp"
"new-cmp/cmpc.lsp"
"new-cmp/cmpcall.lsp"
"new-cmp/cmpcatch.lsp"
"new-cmp/cmpcffi.lsp"
"new-cmp/cmpclos.lsp"
"new-cmp/cmpdata.lsp"
"new-cmp/cmpdefs.lsp"
"new-cmp/cmpenv.lsp"
"new-cmp/cmpeval.lsp"
"new-cmp/cmpflet.lsp"
"new-cmp/cmpform.lsp"
"new-cmp/cmpfun.lsp"
"new-cmp/cmpglobals.lsp"
"new-cmp/cmpif.lsp"
"new-cmp/cmpinit.lsp"
"new-cmp/cmplam.lsp"
"new-cmp/cmplet.lsp"
"new-cmp/cmploc.lsp"
"new-cmp/cmpmac.lsp"
"new-cmp/cmpmain.lsp"
"new-cmp/cmpmap.lsp"
"new-cmp/cmpmulti.lsp"
"new-cmp/cmpname.lsp"
"new-cmp/cmpnum.lsp"
"new-cmp/cmpopt.lsp"
"new-cmp/cmppackage.lsp"
"new-cmp/cmppass.lsp"
"new-cmp/cmpprop.lsp"
"new-cmp/cmpspecial.lsp"
"new-cmp/cmpstack.lsp"
"new-cmp/cmpstructures.lsp"
"new-cmp/cmptables.lsp"
"new-cmp/cmptag.lsp"
"new-cmp/cmptop.lsp"
"new-cmp/cmptranslate.lsp"
"new-cmp/cmptype.lsp"
"new-cmp/cmptypes.lsp"
"new-cmp/cmputil.lsp"
"new-cmp/cmpvar.lsp"
"new-cmp/sysfun.lsp"
)))

(mapcar 'find-file ecl-files)

(defun ecl-revert ()
  (interactive)
  (mapcar '(lambda (x) (let ((a (find-buffer-visiting x)))
			 (and a (switch-to-buffer a)
			      (revert-buffer t t))))
	  ecl-files))
