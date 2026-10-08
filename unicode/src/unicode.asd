
(in-package #:asdf-user)

(defsystem unicode
  :name "unicode"
  :author "Roy Arne Gangstad <roy.gangstad@gmail.com>"
  :maintainer "Roy Arne Gangstad <roy.gangstad@gmail.com>"
  :license "GNU Affero General Public License, version 3."
  :depends-on ("system")
  :serial t
  :components ((:file "unicode")

               (:file "configuration")

               (:file "code-point")

               (:module utf-8
                :serial t
                :depends-on ("unicode" "code-point")
                :components ((:file "utf-8")
                             (:file "type-definitions")
                             (:file "encoding-and-decoding")
                             (:file "vectors")
                             (:file "comparisons")
                             (:file "compatibility")))

               (:module table
                :serial t
                :depends-on ("unicode" "code-point" utf-8)
                :components ((:file "table")
                             (:file "type-definitions")
                             (:file "construction")
                             (:file "lookup")
                             (:file "fnv-1a")
                             (:file "stream")
                             (:file "unicodedata")))

               (:module rope
                :serial t
                :depends-on ("unicode" utf-8)
                :components ((:file "rope")
                             (:file "type-definitions")
                             (:file "operations")
                             (:file "fnv-1a")
                             (:file "compatibility")))))
