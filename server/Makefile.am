SUBDIRS= . yslib godssenki
ignore : .svnignore
	find -type d |sed -e '/\.svn/d' | xargs svn propset svn:ignore --file .svnignore
