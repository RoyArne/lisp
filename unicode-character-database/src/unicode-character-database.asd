
(in-package #:asdf-user)

(defsystem unicode-character-database
  :name "unicode-character-database"
  :author "Roy Arne Gangstad <roy.gangstad@gmail.com>"
  :maintainer "Roy Arne Gangstad <roy.gangstad@gmail.com>"
  :license "GNU Affero General Public License, version 3."
  :depends-on ("unicode" "split-sequence")
  :serial t
  :components ((:file "unicode-character-database")
               (:file "configuration")
               ;(:file "pathnames")
               (:file "parser")
               (:file "unicodedata")))
