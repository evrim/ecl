;;;;  Copyright (c) 1984, Taiichi Yuasa and Masami Hagiya.
;;;;  Copyright (c) 1990, Giuseppe Attardi.
;;;;
;;;;    This program is free software; you can redistribute it and/or
;;;;    modify it under the terms of the GNU Library General Public
;;;;    License as published by the Free Software Foundation; either
;;;;    version 2 of the License, or (at your option) any later version.
;;;;
;;;;    See file '../Copyright' for full details.

;;;;	module routines

(in-package "SYSTEM")

(defvar *modules* nil)

(defun provide (module-name)
  (setq *modules*
        (adjoin (string module-name) *modules* :test #'string=)))


(defun require (module-name
                &optional (pathname (string-downcase (string module-name))))
  (let ((*default-pathname-defaults* #P""))
    (unless (member (string module-name)
                    *modules* :test #'string=)
      (if (atom pathname)
	  (load pathname)
	  (dolist (p pathname)
	    (load p))))))

