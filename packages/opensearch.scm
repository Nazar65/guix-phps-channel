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

(define-module (packages opensearch)
  #:use-module (guix packages)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages)
  #:use-module (guix download)
  #:use-module (guix licenses)
  #:use-module (gnu packages base)
  #:use-module (gnu packages java)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages pkg-config)
  #:use-module ((guix licenses) #:prefix license:))

(define-public opensearch
  (package
    (name "opensearch")
    (version "2.14.0")
    (source (origin
              (method url-fetch)
	      (uri
	       (string-append "https://artifacts.opensearch.org/releases/bundle/opensearch/" version "/opensearch-" version "-linux-x64.tar.gz"))
	      (sha256
               (base32
		"0xpcqlz4y32flzhdk9a0cqlffs77rljhg32q1ssxlxl3f7dyswil"))
              (patches
	       (search-patches
                "patches/opensearch.patch"
                ))))
    (build-system gnu-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (delete 'build)
         (replace 'install
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (bin (string-append out "/bin"))
                    (config (string-append out "/config"))
                    (lib (string-append out "/lib"))
                    (modules (string-append out "/modules"))
                    (plugins (string-append out "/plugins"))
                    (jdk-opensearch (string-append out "/jdk"))
                    (coreutils (string-append (assoc-ref inputs "coreutils")
                                    "/bin")))
               (copy-recursively "./bin" bin)
               (copy-recursively "./config" config)
               (copy-recursively "./lib" lib)
               (copy-recursively "./modules" modules)
               (copy-recursively "./plugins" plugins)
               (wrap-program (string-append out "/bin/opensearch")
                 `("JAVA_HOME" ":" = (,(assoc-ref inputs "jdk")))
                 `("PATH" ":" prefix ,(list coreutils))
                 `("LD_LIBRARY_PATH" ":" prefix
                                      (,(string-append out "plugins/opensearch-knn/lib"))))
               (wrap-program (string-append out "/bin/opensearch-plugin")
                 `("JAVA_HOME" ":" = (,(assoc-ref inputs "jdk"))))
               ))))
       #:parallel-build? #f
       #:tests? #f))
    (inputs
     `(("jdk" ,openjdk11)
       ("coreutils" ,coreutils)))
    (home-page "https://github.com/opensearch-project")
    (synopsis "Open Source, Distributed, RESTful Search Engine")
    (description "OpenSearch is a community-driven, Apache 2.0-licensed open source search and analytics suite that makes it easy to ingest, search, visualize, and analyze data. Developers build with OpenSearch for use cases such as application search, log analytics, data observability, data ingestion, and more.")
    (license (non-copyleft "file://COPYING"
                           "See COPYING file in the distribution."))))
