#!/bin/sh
mkdir -p .build
pdflatex -d --shell-escape --into=.build main.tex && cp .build/main.pdf .
