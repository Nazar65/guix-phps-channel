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
  #:use-module (packages composer)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages)
  #:use-module (guix git-download)
  #:use-module (guix licenses)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages pkg-config)
  #:use-module ((guix licenses) #:prefix license:))

(define-public phpfixer
  (package
    (name "phpfixer")
    (version "3.4.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/FriendsOfPHP/PHP-CS-Fixer/")
                    (commit "47177af1cfb9dab5d1cc4daf91b7179c2efe7fad")))
              (sha256
               (base32
                "1w23vajn0g7q9my680ydjq70ywpqw0xi92k5slrg65d2si9x2wmf"))))
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
		    (vendor (string-append out "/vendor"))
                    (executable "php-cs-fixer"))
	       (mkdir-p vendor)
	       (copy-recursively "./" out)
               (install-file executable bin)
	       (invoke "composer" "install"))
             #t)))
       #:parallel-build? #f
       #:tests? #f)) ; There are no tests.
    (inputs
     `(("composer" ,composer1)
      ))
    (home-page "https://github.com/FriendsOfPHP/PHP-CS-Fixer/")
    (synopsis "The PHP Coding Standards Fixer (PHP CS Fixer)")
    (description
     "This tool fixes your code to follow standards; whether you want to follow PHP coding standards as defined in the PSR-1, PSR-2, etc., or other community driven ones like the Symfony one. You can also define your (team's) style through configuration.")
    (license (non-copyleft "file://COPYING"
                           "See COPYING file in the distribution."))))
