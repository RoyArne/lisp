
(in-package #:asdf-user)

(defsystem unicode
  :name "unicode"
  :author "Roy Arne Gangstad <roy.gangstad@gmail.com>"
  :maintainer "Roy Arne Gangstad <roy.gangstad@gmail.com>"
  :license "GNU Affero General Public License, version 3."
  :depends-on ("unicode")
  :components ((:file "string")))
