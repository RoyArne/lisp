;;;; This is "string/src/string.asd".

(in-package #:asdf-user)

(defsystem string
  :name "string"
  :author "Roy Arne Gangstad <roy.gangstad@gmail.com>"
  :maintainer "Roy Arne Gangstad <roy.gangstad@gmail.com>"
  :license "GNU Affero General Public License, version 3."
  :depends-on ("unicode")
  :components ((:file "string")
               (:file "type-definitions")
               (:file "comparison-functions")
               (:file "compatibility")))
