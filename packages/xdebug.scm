;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2013, 2016 Ludovic Courtès <ludo@gnu.org>
;;; Copyright © 2015, 2016 Mark H Weaver <mhw@netris.org>
;;; Copyright © 2015 Eric Bavier <bavier@member.fsf.org>
;;; Copyright © 2016, 2017 Leo Famulari <leo@famulari.name>
;;; Copyright © 2017, 2021 Efraim Flashner <efraim@flashner.co.il>
;;; Copyright © 2017 Marius Bakke <mbakke@fastmail.com>
;;; Copyright © 2018, 2019, 2020 Tobias Geerinckx-Rice <me@tobias.gr>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (packages xdebug)
  #:use-module (guix packages)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages)
  #:use-module (php81)
  #:use-module (guix download)
  #:use-module (guix licenses)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages pkg-config)
  #:use-module ((guix licenses) #:prefix license:))

(define-public xdebug-php-8.1
  (package
    (name "xdebug-php-8.1")
    (version "3.3.2")
    (source (origin
              (method url-fetch)
              (uri
               (string-append
                    "https://github.com/xdebug/xdebug/archive/refs/tags/" version ".tar.gz"))
	      (sha256
               (base32
		"0hq708kbbg4absq7c1sfvlvh6750jlsk1fz109ijynjdik5h284x"))))

    (build-system gnu-build-system)
    (arguments
     `(#:configure-flags (list "--enable-xdebug")
       #:phases
       (modify-phases %standard-phases
	 (add-before 'install 'not-install-modules
	    (lambda _
	      (invoke "sed" "-i" "s/@$(INSTALL) modules\\/\\* $(INSTALL_ROOT)$(EXTENSION_DIR)//" "./Makefile")))
	  (add-before 'configure 'run-phpize
	    (lambda _
	      (invoke "phpize")))
	  (add-before 'install 'move-xdebug-extension
	    (lambda* (#:key outputs #:allow-other-keys)
	      (let* ((out (assoc-ref outputs "out"))
		     (lib (string-append out "/lib")))
		(install-file "./modules/xdebug.so" lib)))))
       #:parallel-build? #f
       #:tests? #f))
     (native-inputs
     `(("autoconf" ,autoconf)))
    (inputs
     `(("php" ,php81)))
    (home-page "https://xdebug.org/")
    (synopsis "Xdebug is an extension for PHP, and provides a range of features to improve the PHP development experience.")
    (description "See https://xdebug.org/ for more information and documentation.")
    (license (non-copyleft "file://COPYING"
                           "See COPYING file in the distribution."))))
