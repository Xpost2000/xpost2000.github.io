#|
	Common Lisp page generator for Xpost2000.github.io

	This is copy and pasted from the other file with changes. Will make it use less
	files later, or never.
|#
(load "htmlify.cl")

;; whatever this is way faster to do lol
(defclass project ()
  ((title
    :initarg :title
    :accessor project-title
    :initform (error "Please give me a title sirrah!"))
   (description
    :initarg :description
    :accessor project-description
    :initform (error "Please give me a description sirrah!"))
   (thumbnail-source
    :initarg :thumbnail
    :accessor project-thumbnail-location
    :initform (error "Please give me a thumbnail sirrah!"))))

(defmethod print-object ((object project) stream)
  (print `(project :title ,(project-title object)
                   :description ,(project-description object)
                   :thumbnail ,(project-thumbnail-location object))
         stream))
(defun project (&key title description thumbnail)
  (make-instance 'project
                 :title title
                 :description description
                 :thumbnail thumbnail))

(defparameter *projects* '())
(defun clear-projects ()
  (setf *projects* '()))
(defun add-projects (&rest projects)
  (dolist (project projects)
    (push project *projects*)))

;; converting the old format to the new one which is specified
;; as code.
;; This does technically allow me to specify new projects in the old format
;; but I don't really want to do that lol.
(defun directory-file-structure->lisp-file ()
  (let ((project-subdirectories
          (map 'list
               #'enough-namestring
               (uiop:subdirectories "projects/"))))
    (loop for directory in project-subdirectories
          collect
          (let ((lines (file-lines (concatenate 'string directory "/info.txt"))))
            (project :title (first lines)
                     :description (reduce (lambda (result line)
                                            (concatenate 'string result " " line))
                                          (subseq lines 3))
                     :thumbnail (concatenate 'string directory "/" (second lines)))))))

(defun generate-project-cards (projects)
  (map 'list
       (lambda (project)
         `(:li
           ((:p ((:class "project-title")) ,(project-title project))
            (:div ((:class "project-description"))
             ((:img ((:class "project-thumb")
                     (:src ,(project-thumbnail-location project))) "")
              (:p ,(project-description project)))))))
       projects))

;; a meta program to meta program a website.
;; this is only wrapped in a progn to "scope"
(defun build-preamble ()
    (with-open-file (*standard-output* "projects-list1.cl"
                                       :direction :output
                                       :if-exists :supersede
                                       :external-format :utf-8)
      (print `(add-projects ,@(directory-file-structure->lisp-file))))
  (load "projects-list.cl")
  (load "projects-list1.cl"))

(defun build () 
  (build-preamble)
  (with-open-file (*standard-output* "index_test.html" :direction :output :if-exists :supersede :external-format :utf-8)
    (write-string
     (compile-html
      (with-common-page-template
        :page-title "Projects"
        :body
        `((:h1 "My Projects")
          (:br)
          (:p "This is my projects section. This is not necessarily a portfolio page, but may contain portfolio projects. Thesee are just C projects
	that mostly consist of either tools or games. Maybe the occasional web development project, but those are pretty rare. Most things here are probably on my Github.")
          (:br)
          (:p ("This like the blog page should've been generated by a Common Lisp generator if nothing went wrong. " (:b "This page doesn't really contain any released games. Those are just on itch.io")))
          (:ul
            ((:id "project-listing"))
            ,(generate-project-cards *projects*))))))))

(build)
