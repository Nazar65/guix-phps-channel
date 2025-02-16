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

(define-module (packages php-spx)
  #:use-module (guix packages)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages)
  #:use-module (packages php)
  #:use-module (guix download)
  #:use-module (guix licenses)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages pkg-config)
  #:use-module ((guix licenses) #:prefix license:))

(define-public php-spx
  (package
    (name "php-spx")
    (version "v0.4.18")
    (source (origin
              (method url-fetch)
              (uri
               (string-append
                    "https://github.com/NoiseByNorthwest/php-spx/archive/refs/tags/" version ".tar.gz"))
	      (sha256
               (base32
		"0452gl99qwrd63i58i9ym97spxiyqbpxlwq77f0cbbmm1h45818z"))))

    (build-system gnu-build-system)
    (arguments
     `(#:configure-flags (list (string-append "--with-zlib-dir=" (assoc-ref %build-inputs "zlib")))
       #:phases
       (modify-phases %standard-phases
         (add-before 'build 'fix-Makefiles
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let ((out (assoc-ref outputs "out")))
               (substitute* (find-files "." "Makefile")
                 (("INSTALL_ROOT)")
                  (string-append "INSTALL_ROOT)" out)))
               #t)))
	 (add-before 'install 'not-install-modules
	    (lambda _
	      (invoke "sed" "-i" "s/@$(INSTALL) modules\\/\\* $(INSTALL_ROOT)$(EXTENSION_DIR)//" "./Makefile")))
	  (add-before 'configure 'run-phpize
	    (lambda _
	      (invoke "phpize")))
	  (add-before 'install 'move-spx-extension
	    (lambda* (#:key inputs outputs #:allow-other-keys)
	      (let* ((out (assoc-ref outputs "out"))
		     (lib (string-append out "/lib")))
		(install-file "./modules/spx.so" lib)))))
       #:parallel-build? #f
       #:tests? #f))
     (native-inputs
      `(("autoconf" ,autoconf)
        ("zlib" ,zlib)))
    (inputs
     `(("php" ,php81)
       ("zlib" ,zlib)))
    (home-page "https://github.com/NoiseByNorthwest/php-spx")
    (synopsis "SPX - A simple profiler for PHP")
    (description "SPX, which stands for Simple Profiling eXtension, is just another profiling extension for PHP")
    (license (non-copyleft "file://COPYING"
                           "See COPYING file in the distribution."))))
