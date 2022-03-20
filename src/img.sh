#!/bin/sh -e
# Ten Digits image processing script, based on: https://git.sr.ht/~rostiger/nchrs/blob/main/src/batchVariants.sh
SRC="img"
DST="../assets/img"
SIZES=( 240 )
MAXWIDTH=1600
COLORS=4
NOTES=''

function resize () {
	
  # prevent an endless loop 
  [[ $file == *"${DST}/*"* ]] && continue 

  for file in $1; do
		[ -f "$file" ] || continue

		# create output path
		path=$(dirname $file)   # just/the/path    
		name=$(basename $file)  # filename.ext
		fileBase="${name%%.*}"  # filename
		fileExt="${name#*.}"    # ext
	
		dst="${path/$SRC/$DST}"    
	
		# existing images are skipped (delete images if they were updated)    
		# create the output path (and parents) if it doesn't exist
		if [[ ! -d "$dst" ]]; then 
	  	mkdir -p $dst
		fi
			
		# copy the file as is if it doesn't have the right extension
		if [[ "$fileExt" != "jpg" && "$fileExt" != "jpeg" && "$fileExt" != "png" && "$fileExt" != "DS_Store" ]]; then
			cp -r $file $dst
			NOTES="${NOTES} Copied ${file}"
			continue
		fi
		
		# create smaller sizes for responsive image selection
		NOTES="${NOTES}${file}"
		if [[ "$fileExt" == "jpg" || "$fileExt" == "jpeg" || "$fileExt" == "png" ]]; then
		# get the width of the image
			width=$(identify -format "%w" "$file")> /dev/null
			for size in "${SIZES[@]}"; do
	  		# define output path and file
				output="$dst/$fileBase-${size}.png"
	  		if [[ ! -f $output ]]; then
				# resize only  if original image is greater than or equal to (ge) the current size
				if [[ $width -ge $size ]]; then
		  		NOTES="${NOTES} | ${size} "
						convert $file -strip -auto-orient -resize $size -dither FloydSteinberg -colorspace Gray -colors $COLORS $output
				else
					#dither only
		  		NOTES="${NOTES} | ${width} "
						convert $file -strip -auto-orient -dither FloydSteinberg -colorspace Gray -colors $COLORS $output
					fi
	  		else NOTES="${NOTES} | √ "
	  		fi
			done
		else NOTES="${NOTES} | ---"
		fi
		# Strip EXIF data and resize high res image
		output="$dst/$name"
		if [[ ! -f $output ]]; then
			if [[ $width -gt $MAXWIDTH ]]; then
		  	convert $file -strip -auto-orient -resize $MAXWIDTH $output
		  	NOTES="${NOTES} | ${MAXWIDTH}"
	  	else
		  	convert $file -strip -auto-orient $output
		  	NOTES="${NOTES} | ${width}"
	  	fi
		else NOTES="${NOTES} | √"
		fi
  done
  echo $NOTES$'\r';
  NOTES='';
}

# find all file in the source folder and run resize() on each
find $SRC | while read file; do resize "${file}"; done
