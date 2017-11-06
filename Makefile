all:
	pdflatex conference_poster_2.tex
	bibtex conference_poster_2
	pdflatex conference_poster_2.tex
