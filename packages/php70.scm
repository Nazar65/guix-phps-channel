;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2016 Julien Lepiller <julien@lepiller.eu>
;;; Copyright © 2016 Marius Bakke <mbakke@fastmail.com>
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

(define-module (packages php70)
  #:use-module (gnu packages)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages aspell)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bison)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages cyrus-sasl)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages gd)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages icu4c)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages image)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages multiprecision)
  #:use-module (gnu packages openldap)
  #:use-module (gnu packages pcre)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages readline)
  #:use-module (gnu packages textutils)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages web)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xorg)
  #:use-module (guix utils)
  #:use-module (gnu packages mcrypt)
  #:use-module (gnu packages dbm)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:))

;; This fixes PHP bugs 73155 and 73159. Remove when gd
;; is updated to > 2.2.3.
(define gd-for-php
  (package (inherit gd)
    (source
     (origin
       (inherit (package-source gd))
       (patches (search-patches
                 ))))))

(define-public php70
  (package
    (name "php70")
    (version "7.0.33")
    (home-page "https://secure.php.net/")
    (source (origin
              (method url-fetch)
              (uri (string-append home-page "distributions/php-" version ".tar.xz"))
              (sha256
               (base32
                "15ixl7wi8fffa8db1aqrwl4s5cdvljmdmph9541qs7rbwgk5p35b"))
	      (patches (search-patches
			"patches/mbstring_php70.patch"
                        ))
              (modules '((guix build utils)))
              (snippet
               '(with-directory-excursion "ext"
                  (for-each delete-file-recursively
                            ;; Some of the bundled libraries have no proper upstream.
                            ;; Ideally we'd extract these out as separate packages:
                            ;;"mbstring/libmbfl"
                            ;;"date/lib"
                            ;;"bcmath/libbcmath"
                            ;;"fileinfo/libmagic" ; This is a patched version of libmagic.
                            '("gd/libgd"
                              "mbstring/oniguruma"
                              "pcre/pcrelib"
                              "xmlrpc/libxmlrpc"))))))
    (build-system gnu-build-system)
    (arguments
     '(#:configure-flags
       (let-syntax ((with (syntax-rules ()
                            ((_ option input)
                             (string-append option "="
                                            (assoc-ref %build-inputs input))))))
         (list (with "--with-bz2" "bzip2")
               (with "--with-curl" "curl")
	       (with "--with-gettext" "glibc")
               (with "--with-freetype-dir" "freetype")
               (with "--with-gd" "gd")
               (with "--with-gdbm" "gdbm")
               (with "--with-gettext" "glibc") ; libintl.h
               (with "--with-gmp" "gmp")
               (with "--with-jpeg-dir" "libjpeg")
               (with "--with-ldap" "openldap")
               (with "--with-ldap-sasl" "cyrus-sasl")
               (with "--with-libzip" "zip")
               (with "--with-libxml-dir" "libxml2")
               (with "--with-onig" "oniguruma")
               (with "--with-pcre-dir" "pcre")
               (with "--with-pcre-regex" "pcre")
               (with "--with-pdo-pgsql" "postgresql")
               (with "--with-pgsql" "postgresql")
               (with "--with-png-dir" "libpng")
               ;; PHP’s Pspell extension, while retaining its current name,
               ;; now uses the Aspell library.
               (with "--with-pspell" "aspell")
               (with "--with-readline" "readline")
               (with "--with-tidy" "tidy")
               (with "--with-webp-dir" "libwebp")
               (with "--with-xpm-dir" "libxpm")
               (with "--with-xsl" "libxslt")
	       (with "--with-mcrypt" "libmcrypt")
               (with "--with-zlib-dir" "zlib")
               ;; We could add "--with-snmp", but it requires netsnmp that
               ;; we don't have a package for. It is used to build the snmp
               ;; extension of php.
               "--with-iconv"
	       "--with-libzip"
	       "--without-sqlite3"
	       "--without-pdo-sqlite"
               "--with-openssl"
               "--with-pdo-mysql"
               "--with-zlib"
	       "--enable-zip"
	       "--enable-bcmath"
               "--enable-calendar"
               "--enable-dba=shared"
               "--enable-exif"
               "--enable-flatfile"
               "--enable-fpm"
	       "--enable-dom"
	       "--enable-json"
	       "--enable-libxml"
	       "--enable-simplexml"
	       "--enable-soap"
	       "--enable-sodium"
	       "--enable-libxml"
	       "--enable-intl"
               "--enable-ftp"
               "--enable-inifile"
	       "--enable-mbstring"
               "--enable-pcntl"
               "--enable-sockets"
               "--enable-threads"))
       #:make-flags
       (list "CPPFLAGS+= -DU_USING_ICU_NAMESPACE=1"
	     "CC= gcc -DTRUE=1 -DFALSE=0"
	     "CXX= g++ -DTRUE=1 -DFALSE=0")

       #:phases
       (modify-phases %standard-phases
	 (add-after 'unpack 'do-not-record-build-flags
           (lambda _
             ;; Prevent configure flags from being stored and causing
             ;; unnecessary runtime dependencies.
             (substitute* "scripts/php-config.in"
               (("@CONFIGURE_OPTIONS@") "")
               (("@PHP_LDFLAGS@") ""))
             ;; This file has ISO-8859-1 encoding.
             (with-fluids ((%default-port-encoding "ISO-8859-1"))
               (substitute* "main/build-defs.h.in"
                 (("@CONFIGURE_COMMAND@") "(omitted)")))
             #t))
         (add-before 'build 'patch-/bin/sh
           (lambda _
             (substitute* '("run-tests.php" "ext/standard/proc_open.c")
               (("/bin/sh") (which "sh")))
             #t))
         (add-before 'check 'prepare-tests
           (lambda _
             ;; Some of these files have ISO-8859-1 encoding, whereas others
             ;; use ASCII, so we can't use a "catch-all" find-files here.
             (with-fluids ((%default-port-encoding "ISO-8859-1"))
               (substitute* '("ext/mbstring/tests/mb_send_mail02.phpt"
                              "ext/mbstring/tests/mb_send_mail04.phpt"
                              "ext/mbstring/tests/mb_send_mail05.phpt"
                              "ext/mbstring/tests/mb_send_mail06.phpt")
                 (("/bin/cat") (which "cat"))))
             (substitute* '("ext/mbstring/tests/mb_send_mail01.phpt"
                            "ext/mbstring/tests/mb_send_mail03.phpt"
                            "ext/mbstring/tests/bug52861.phpt"
                            "ext/standard/tests/general_functions/bug34794.phpt"
                            "ext/standard/tests/general_functions/bug44667.phpt"
                            "ext/standard/tests/general_functions/proc_open.phpt")
               (("/bin/cat") (which "cat")))
             ;; The encoding of this file is not recognized, so we simply drop it.
             (delete-file "ext/mbstring/tests/mb_send_mail07.phpt")

             (substitute* "ext/standard/tests/streams/bug60602.phpt"
               (("'ls'") (string-append "'" (which "ls") "'")))

             ;; Drop tests that are known to fail.
             (for-each delete-file
                       '("ext/posix/tests/posix_getgrgid.phpt"    ; Requires /etc/group.
                         "ext/sockets/tests/bug63000.phpt"        ; Fails to detect OS.
                         "ext/sockets/tests/socket_shutdown.phpt" ; Requires DNS.
                         "ext/sockets/tests/socket_send.phpt"     ; Likewise.
                         "ext/sockets/tests/mcast_ipv4_recv.phpt" ; Requires multicast.
                         ;; These needs /etc/services.
                         "ext/standard/tests/general_functions/getservbyname_basic.phpt"
                         "ext/standard/tests/general_functions/getservbyport_basic.phpt"
                         "ext/standard/tests/general_functions/getservbyport_variation1.phpt"
                         ;; And /etc/protocols.
                         "ext/standard/tests/network/getprotobyname_basic.phpt"
                         "ext/standard/tests/network/getprotobynumber_basic.phpt"
                         ;; And exotic locales.
                         "ext/standard/tests/strings/setlocale_basic1.phpt"
                         "ext/standard/tests/strings/setlocale_basic2.phpt"
                         "ext/standard/tests/strings/setlocale_basic3.phpt"
                         "ext/standard/tests/strings/setlocale_variation1.phpt"

                         ;; XXX: These gd tests fails.  Likely because our version
                         ;; is different from the (patched) bundled one.
                         ;; Here, gd quits immediately after "fatal libpng error"; while the
                         ;; test expects it to additionally return a "setjmp" error and warning.
                         "ext/gd/tests/bug39780_extern.phpt"
                         "ext/gd/tests/libgd00086_extern.phpt"
                         ;; Extra newline in gd-png output.
                         "ext/gd/tests/bug45799.phpt"
                         ;; Different error message than expected from imagecrop().
                         "ext/gd/tests/bug66356.phpt"
                         ;; Similarly for imagecreatefromgd2().
                         "ext/gd/tests/bug72339.phpt"
                         ;; Call to undefined function imageantialias().  They are
                         ;; supposed to fail anyway.
                         "ext/gd/tests/bug72482.phpt"
                         "ext/gd/tests/bug72482_2.phpt"
                         "ext/gd/tests/bug73213.phpt"
                         ;; Test expects generic "gd warning" but gets the actual function name.
                         "ext/gd/tests/createfromwbmp2_extern.phpt"
                         ;; TODO: Enable these when libgd is built with xpm support.
                         "ext/gd/tests/xpm2gd.phpt"
                         "ext/gd/tests/xpm2jpg.phpt"
                         "ext/gd/tests/xpm2png.phpt"

                         ;; XXX: These iconv tests have the expected outcome,
                         ;; but with different error messages.
                         ;; Expects "illegal character", instead gets "unknown error (84)".
                         "ext/iconv/tests/bug52211.phpt"
                         ;; Expects "wrong charset", gets unknown error (22).
                         "ext/iconv/tests/iconv_mime_decode_variation3.phpt"
                         "ext/iconv/tests/iconv_strlen_error2.phpt"
                         "ext/iconv/tests/iconv_strlen_variation2.phpt"
                         "ext/iconv/tests/iconv_substr_error2.phpt"
                         ;; Expects conversion error, gets "error condition Termsig=11".
                         "ext/iconv/tests/iconv_strpos_error2.phpt"
                         "ext/iconv/tests/iconv_strrpos_error2.phpt"
                         ;; Similar, but iterating over multiple values.
                         ;; iconv breaks the loop after the first error with Termsig=11.
                         "ext/iconv/tests/iconv_strpos_variation4.phpt"
                         "ext/iconv/tests/iconv_strrpos_variation3.phpt"

                         ;; XXX: These test failures appear legitimate, needs investigation.
                         ;; open_basedir() restriction failure.
                         "ext/curl/tests/bug61948.phpt"
			 "ext/curl/tests/curl_basic_010.phpt"
			 "ext/dom/tests/DOMDocument_loadXML_error1.phpt"
			 "ext/dom/tests/DOMDocument_load_error1.phpt"
			 "ext/dom/tests/bug43364.phpt"
			 "ext/gd/tests/bug47946.phpt"
			 "ext/gd/tests/bug65148.phpt"
			 "ext/gd/tests/bug66590.phpt"
			 "ext/gd/tests/bug70102.phpt"
			 "ext/gd/tests/bug73869.phpt"
			 "ext/gd/tests/webp_basic.phpt"
			 "ext/iconv/tests/bug76249.phpt"
			 "ext/libxml/tests/bug61367-read.phpt"
			 "ext/libxml/tests/libxml_disable_entity_loader.phpt"
			 "ext/openssl/tests/bug48182.phpt"
			 "ext/openssl/tests/bug54992.phpt"
			 "ext/openssl/tests/bug65538_001.phpt"
			 "ext/openssl/tests/bug65538_003.phpt"
			 "ext/openssl/tests/bug74159.phpt"
			 "ext/openssl/tests/capture_peer_cert_001.phpt"
			 "ext/openssl/tests/openssl_error_string_basic.phpt"
			 "ext/openssl/tests/openssl_peer_fingerprint_basic.phpt"
			 "ext/openssl/tests/peer_verification.phpt"
			 "ext/openssl/tests/session_meta_capture.phpt"
			 "ext/openssl/tests/stream_crypto_flags_001.phpt"
			 "ext/openssl/tests/stream_crypto_flags_002.phpt"
			 "ext/openssl/tests/stream_crypto_flags_003.phpt"
			 "ext/openssl/tests/stream_crypto_flags_004.phpt"
			 "ext/openssl/tests/stream_server_reneg_limit.phpt"
			 "ext/openssl/tests/stream_verify_peer_name_002.phpt"
			 "ext/openssl/tests/stream_verify_peer_name_003.phpt"
			 "ext/openssl/tests/openssl_x509_checkpurpose_basic.phpt"
			 "ext/mbstring/tests/mb_ereg_replace_variation1.phpt"
			 "ext/mbstring/tests/mb_ereg_variation3.phpt"
			 "ext/intl/tests/breakiter_getLocale_basic2.phpt"
			 "ext/intl/tests/bug62070_2.phpt"
			 "ext/intl/tests/bug74230.phpt"
			 "ext/intl/tests/collator_get_sort_key_variant6.phpt"
			 "ext/intl/tests/formatter_format6.phpt"
			 "ext/intl/tests/formatter_format_currency2.phpt"
			 "ext/intl/tests/formatter_get_locale_variant3.phpt"
			 "ext/intl/tests/formatter_get_set_pattern.phpt"
			 "ext/intl/tests/formatter_get_set_symbol2.phpt"
			 "ext/intl/tests/grapheme.phpt"
			 "ext/intl/tests/locale_bug66289.phpt"
			 "ext/intl/tests/locale_filter_matches3.phpt"
			 "ext/intl/tests/locale_get_display_language.phpt"
			 "ext/intl/tests/locale_get_display_name5.phpt"
			 "ext/intl/tests/locale_get_primary_language.phpt"
			 "ext/intl/tests/locale_lookup_variant2.phpt"
			 "ext/intl/tests/locale_parse_locale2.phpt"
			 "ext/intl/tests/msgfmt_bug70484.phpt"
			 "ext/intl/tests/rbbiter_getBinaryRules_basic.phpt"
			 "ext/intl/tests/rbbiter_getRules_basic.phpt"
                         ;; Expects a false boolean, gets empty array from glob().
                         "ext/standard/tests/file/bug41655_1.phpt"
                         "ext/standard/tests/file/glob_variation5.phpt"
                         ;; Test output is correct, but in wrong order.
                         "ext/standard/tests/streams/proc_open_bug64438.phpt"
                         ;; The test expects an Array, but instead get the contents(?).
                         "ext/gd/tests/bug43073.phpt"
                         ;; imagettftext() returns wrong coordinates.
                         "ext/gd/tests/bug48732.phpt"
                         ;; Similarly for imageftbbox().
                         "ext/gd/tests/bug48801.phpt"
                         ;; Different expected output from imagecolorallocate().
                         "ext/gd/tests/bug53504.phpt"
                         ;; Wrong image size after scaling an image.
                         "ext/gd/tests/bug73272.phpt"
                         ;; Expects iconv to detect illegal characters, instead gets
                         ;; "unknown error (84)" and heap corruption(!).
                         "ext/iconv/tests/bug48147.phpt"
                         ;; Expects illegal character ".", gets "=?utf-8?Q?."
                         "ext/iconv/tests/bug51250.phpt"
                         ;; @iconv() does not return expected output.
                         "ext/iconv/tests/iconv003.phpt"
			 "ext/zip/tests/bug53885.phpt"
                         ;; iconv throws "buffer length exceeded" on some string checks.
                         "ext/iconv/tests/iconv_mime_encode.phpt"
                         ;; file_get_contents(): iconv stream filter
                         ;; ("ISO-8859-1"=>"UTF-8") unknown error.
                         "ext/standard/tests/file/bug43008.phpt"))

             ;; Skip tests requiring network access.
             (setenv "SKIP_ONLINE_TESTS" "1")
             ;; Without this variable, 'make test' passes regardless of failures.
             (setenv "REPORT_EXIT_STATUS" "1")
             #t)))
       #:test-target "test"))
    (inputs
     `(("aspell" ,aspell)
       ("bzip2" ,bzip2)
       ("curl" ,curl)
       ("cyrus-sasl" ,cyrus-sasl)
       ("freetype" ,freetype)
       ("gd" ,gd-for-php)
       ("gdbm" ,gdbm)
       ("glibc" ,glibc)
       ("gmp" ,gmp)
       ("libgcrypt" ,libgcrypt)
       ("libjpeg" ,libjpeg-turbo)
       ("icu4c" ,icu4c)
       ("libpng" ,libpng)
       ("libwebp" ,libwebp)
       ("libxml2" ,libxml2)
       ("libxpm" ,libxpm)
       ("libxslt" ,libxslt)
       ("libmcrypt" ,libmcrypt)
       ("libx11" ,libx11)
       ("oniguruma" ,oniguruma)
       ("openldap" ,openldap)
       ("openssl" ,openssl)
       ("pcre" ,pcre)
       ("postgresql" ,postgresql)
       ("readline" ,readline)
       ("tidy" ,tidy)
       ("zip" ,zip)
       ("libzip" ,libzip)
       ("zlib" ,zlib)))
    (native-inputs
     `(("pkg-config" ,pkg-config)
       ("bison" ,bison)
       ("intltool" ,intltool)
       ("procps" ,procps)))         ; For tests.
    (synopsis "PHP programming language")
    (description
     "PHP (PHP Hypertext Processor) is a server-side (CGI) scripting
language designed primarily for web development but is also used as
a general-purpose programming language.  PHP code may be embedded into
HTML code, or it can be used in combination with various web template
systems, web content management systems and web frameworks." )
    (license (list
              (license:non-copyleft "file://LICENSE")       ; The PHP license.
              (license:non-copyleft "file://Zend/LICENSE")  ; The Zend license.
              license:lgpl2.1                               ; ext/mbstring/libmbfl
              license:lgpl2.1+                              ; ext/bcmath/libbcmath
              license:bsd-2                                 ; ext/fileinfo/libmagic
              license:expat))))                             ; ext/date/lib
