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

(define-module (packages phpfixer)
  #:use-module (guix packages)
  #:use-module (packages php72)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages)
  #:use-module (guix download)
  #:use-module (guix licenses)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages pkg-config)
  #:use-module ((guix licenses) #:prefix license:))

(define-public phpfixer
  (package
    (name "phpfixer")
    (version "3.0.0")
    (source (origin
              (method url-fetch)
	      (uri
	       (string-append "https://github.com/FriendsOfPHP/PHP-CS-Fixer/releases/download/v" version "/php-cs-fixer.phar"))
	      (file-name "php-cs-fixer.phar")
	      (sha256
               (base32
		"141rkcr0wbsqnc4s5vg4bk4dmxwigwxa3j0vi5c42b5k1lq3sgwr"))))
    (build-system gnu-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
	 (delete 'configure)
	 (delete 'build)
	 (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (bin (string-append out "/bin"))
                    (executable "php-cs-fixer.phar"))
	       (install-file executable bin)
	       (with-directory-excursion bin
                 (rename-file "php-cs-fixer.phar" "php-cs-fixer"))
	         (chmod (string-append bin  "/php-cs-fixer") #o755))
             #t)))
       #:parallel-build? #f
       #:tests? #f)) ; There are no tests.
  (home-page "https://github.com/FriendsOfPHP/PHP-CS-Fixer/")
  (synopsis "The PHP Coding Standards Fixer (PHP CS Fixer)")
  (description
   "This tool fixes your code to follow standards; whether you want to follow PHP coding standards as defined in the PSR-1, PSR-2, etc., or other community driven ones like the Symfony one. You can also define your (team's) style through configuration.")
  (license (non-copyleft "file://COPYING"
                         "See COPYING file in the distribution."))))
