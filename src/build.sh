#!/bin/sh -e
site=../site
content=content
headerA=../../inc/header-top.htm
headerB=../../inc/header-bottom.htm
sitenav=../../inc/nav.htm
meta=meta.htm
contentFile=content.htm
foot=../../inc/footer.htm
bottom=../../inc/html-bottom.htm
tally=0


rm -rf $site
mkdir -p $site

function process_sidebaritem { 
	if [ -f "${1}.txt" ];then
		markup="$markup<div class='${1}'><h3>${1}</h3><ul>"
		while IFS=',' read val1 val2 val3; do
			if [ $1 == 'notes' ]; then
				markup=$markup"<li>${val1}</li>"
			elif [ $1 == 'links' ]; then
				markup=$markup"<li><a href='${val1}'>${val2}</a></li>"
			elif [ $1 == 'log' ]; then
				markup=$markup"<li><date>${val1}</date> - ${val2}</li>"
			elif [ $1 == 'images' ]; then
				markup=$markup"<li><a href='../assets/img/${val1}.${val2}' title='${val3}'><img src='../assets/img/${val1}-240.png' alt='${val3}' /></a></li>"
			elif [ $1 == 'related' ]; then
				markup=$markup"<li><a href='${val1}.html'>${val1}</a></li>"
			fi
		done < "${1}.txt"
		markup=$markup"</ul></div>";
	fi
}

# List the index
function setupindex {
	echo "<h1>Full site index</h1>" > index/content.htm;
	for f in *; do
		if [ $f != 'index' ]; then
			echo "<a href='${f}.html'>${f}</a><br>" >> index/content.htm;
		fi
	done
	echo "Index built"
}

# Setup topics
cd $content
setupindex;
for f in *; do
	cd $f;
	markup=''
	process_sidebaritem related;
	process_sidebaritem notes;
	process_sidebaritem log;
	process_sidebaritem links;
	process_sidebaritem images;
	topPart=$(cat $headerA $meta $headerB);
	nav=$(cat $sitenav);
	contentText=$(cat $contentFile);
	footer=$(cat $foot);
	closefile=$(cat $bottom);
	mainContent="<main>${contentText}</main>";
	sideBar="<aside>${markup}</aside>";
	echo ${topPart}${nav}"${mainContent}"${sideBar}${footer}${closefile} > ../../$site/${f}.html
	cd ..
	tally=$((tally+1))
done
echo "${tally} topics built"



