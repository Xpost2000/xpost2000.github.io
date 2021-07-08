#|
	Common Lisp page generator for Xpost2000.github.io

	Makes the page generation less painful, mostly.

	This is reusable for generating other pages, although obviously don't
	use this for actual websites since this probably only works for my specific
	scenario. Please use something else, like Clojurescript which actually has good
	libraries to do this thing.

	It only really works with the requirements of this page, as this thing does not even try to pretty print
	correctly. Any attempts at using <PRE> may explode violently.

	I might try to do proper pretty printing later if I don't forget about this tomorrow.

	Basically use a hiccup like format, and common lisp acts as a convenient template engine. At least I don't need
	external html files. It's also easier to write than html itself...
|#

;; grr inclusion order. ASDF would solve this but I'll just order it like this for now
;; since it'll be fine enough.
(load "../generator/htmlify.cl")
(load "../generator/common.cl")

(load "../generator/blog-bro.cl")

(defun build ()
  (html->file
   "index.html"
   (let* ((blog-listing-and-links (install-blog))
          (listing-tags (generate-page-links blog-listing-and-links))
          (links
            (map 'list #'text-link->page-link
                 (loop for item in blog-listing-and-links collect (getf item :link)))))
     (with-common-page-template
       :page-title "Blog"
       :current-link-text "index.html"
       :modeline-links links
       :body
       `(,@(page-content
            "Jerry's Blog"
            (list "Welcome to the blog"
                  ""
                  "Whenever this gets updated, there's going to be some new content here."
                  "This blog listing should be generated by a Common Lisp program in the repository,"
                  "I'm probably going to just talk about whatever I find interesting."
                  ""
                  "Feel free to use the modeline as an alternate form of navigation."
                  )
            '(:p (:b "Listing: "))
            '(:br)
            listing-tags))))))
(build)
