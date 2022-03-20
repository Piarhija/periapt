#!/bin/sh -e

function prompt(){
	read -p "Do you want sidebar $1? " -r yn
	case "${yn}" in
		[Yy]* ) touch $1.txt; break;;
		[Nn]* ) break;;
		* ) echo "Please answer yes or no.";;
	esac
	unset yn;
}

read -p "Topic Name: " name;
if test -d $name; then
	echo "Topic already exists"
else
	read -p "Topic Description: " description;
	cd content;
	mkdir $name;
	cd $name;
	touch content.htm
	title="$(tr '[:lower:]' '[:upper:]' <<< ${name:0:1})${name:1}"
	echo "<h1>${title}</h1>" > content.htm
	touch meta.htm
	echo "<title>${name}</title><meta name='description' content='${description}' />" > meta.htm
	prompt images;
	prompt links;
	prompt log;
	prompt notes;
	prompt related;
fi