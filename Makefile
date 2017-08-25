all:
	pdflatex conference_poster_2.tex
	bibtex conference_poster_2
	pdflatex conference_poster_2.tex

postr:	2017_GLEON.Rmd
	Rscript -e "postr::render('2017_GLEON.Rmd', poster_width = 900, aspect_ratio = 1.333)"
	Rscript -e "postr::render('2017_GLEON.html', poster_width = 900, aspect_ratio = 1.333)"
	convert 2017_GLEON.png -resize 2550x3400 resize_2017_GLEON.png
	

