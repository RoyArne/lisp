
(in-package #:asdf-user)

(defsystem system
  :name "system"
  :author "Roy Arne Gangstad <roy.gangstad@gmail.com>"
  :maintainer "Roy Arne Gangstad <roy.gangstad@gmail.com>"
  :license "GNU Affero General Public License, version 3."
  :serial t
  :components ((:module sequence
                :serial t
                :components ((:file "vector")))))
