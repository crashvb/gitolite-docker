#!/bin/bash

git cat-file blob HEAD:README.md | pandoc --css=test.css --from=markdown_github --output=$GIT_DIR/README.html --to=html
