
(in-package #:asdf-user)

(defsystem unicode-character-database
  :name "unicode-character-database"
  :author "Roy Arne Gangstad <roy.gangstad@gmail.com>"
  :maintainer "Roy Arne Gangstad <roy.gangstad@gmail.com>"
  :license "GNU Affero General Public License, version 3."
  :depends-on ("unicode" "split-sequence")
  :serial t
  :components ((:file "unicode-character-database")
               (:file "files")
               (:file "parser")

               (:module ucd
                :serial t
                :depends-on ("unicode-character-database" "files" "parser")
                :components ((:file "unicodedata")
                             (:file "proplist")))
               
               (:file "common-lisp")))
