# guix-phps-channel
This repository (should) contains all php's packagaes (for the Guix OS) that required for the php development.
If some of them missing, please contact me via email nazarn96@gmail.com

# list of packages

  1. Guix php72
  2. Guix php74
  3. Guix composer
  4. Guix php xdebug
  5. Guix php-cs-fixer

# Usage
To use this channel, add to your ~.config/guix/channels.scm~:

#+begin_src scheme
(cons* (channel
  (name 'guix-phps)
  (url "https://github.com/Nazar65/guix-phps-channel")
  (introduction
    (make-channel-introduction
      "5c31dba5f3a5bb1b1f49305576bfec68efc39d71"
      (openpgp-fingerprint
       "736A C00E 1254 378B A982  7AF6 9DBE 8265 81B6 4490"))))
       %default-channels)
#+end_src

Then run ~guix pull~ to be able to install packages.

