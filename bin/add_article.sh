#!/bin/bash

ARTICLE_TITLE=

while [[ $ARTICLE_TITLE = "" ]]; do
	echo "Please give your article a title:"
	read ARTICLE_TITLE
done

bundle exec middleman article "$ARTICLE_TITLE"
