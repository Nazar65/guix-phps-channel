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

(define-module (packages composer)
  #:use-module (guix packages)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages)
  #:use-module (guix download)
  #:use-module (guix licenses)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages pkg-config)
  #:use-module ((guix licenses) #:prefix license:))

(define-public composer
  (package
    (name "composer")
    (version "2.6.6")
    (source (origin
              (method url-fetch)
	      (uri
	       (string-append "https://getcomposer.org/download/" version "/composer.phar"))
	      (file-name "composer.phar")
	      (sha256
               (base32
		"055khpw0j8zmax3j9yma6qz9cdw5dnri218wiwhlnz1wqw0h4q3j"))))
    (build-system gnu-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
	 (delete 'configure)
	 (delete 'build)
	 (delete 'patch-source-shebangs)
	 (delete 'patch-generated-file-shebangs)
	 (delete 'patch-shebangs)
	 (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (bin (string-append out "/bin")))
	       (mkdir-p bin)
	       (install-file "./composer.phar" bin)
	       (with-directory-excursion bin
                 (rename-file "composer.phar" "composer"))
	       (chmod (string-append bin  "/composer") #o755)
               #t))))
       #:parallel-build? #f
       #:tests? #f))
    (home-page "https://getcomposer.org/ ")
    (synopsis "Composer helps you declare, manage, and install dependencies of PHP projects.")
    (description "See https://getcomposer.org/ for more information and documentation.")
    (license (non-copyleft "file://COPYING"
                           "See COPYING file in the distribution."))))
