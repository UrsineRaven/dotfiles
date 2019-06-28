#!/bin/bash
# Source: https://bbs.archlinux.org/viewtopic.php?id=146850
#
# TODO: Improve colors
#       Improve sed commands (there are more than necessary since we're currently only grabbing headers)
#	Only call curl once or make new command for header generation...

if [ ! -n "$FEED_BOOKMARKS" ]; then export FEED_BOOKMARKS=$HOME/.local/share/.feed_bookmarks; fi
if [ ! -d "$FEED_BOOKMARKS" ]; then mkdir -p $FEED_BOOKMARKS; fi

feed() {
	if [ ! -d $FEED_BOOKMARKS ]; then mkdir $FEED_BOOKMARKS; fi

	if [ ! -n "$1" ]; then
		echo -e "\\n \\e[04mUsage\\e[00m\\n\\n   \\e[01;37m\$ feed \\e[01;31m<url>\\e[00m \\e[01;31m<new bookmark?>\\e[00m\\n\\n \\e[04mSee also\\e[00m\\n\\n   \\e[01;37m\$ deef\\e[00m\\n"
		return 1;
	fi

	local rss_source="$(curl --silent $1 | sed -e ':a;N;$!ba;s/\n/ /g')";

	# Set N to be the number of latest news to fetch
	local NEWS=$(echo -e $(curl --silent https://www.archlinux.org/feeds/news/ | awk ' NR == 1 {N = 3 ; while (N) {print;getline; if($0 ~ /<\/item>/) N=N-1} ; sub(/<\/item>.*/,"</item>") ;print}'))
	# Remove some tags 
	rss_source=$(echo -e $NEWS | \
		awk '{
			# uncomment to remove first line which is usually not a news item
			sub(/<lastBuildDate[^>]*>([^>]*>)/,"");sub(/<language[^>]*>([^>]*>)/,"");sub(/<title[^>]*>([^>]*>)/,"");sub(/<link[^>]*>([^>]*>)/,""); 
			while (sub(/<guid[^>]*>([^>]*>)/,"")); 
			while (sub(/<dc:creator[^>]*>([^>]*>)/,""));
			while (sub(/<description[^>]*>([^>]*>)/,"")); print }' | \
		sed -e ':a;N;$!ba;s/\n/ /g')

	if [ ! -n "$rss_source" ]; then
		echo "The feed is empty";
		return 1;
	fi

	# THE RSS PARSER

	# Formatting
	local f_title="\\\\e[01;31m"
	local f_descr="\\\\e[00;37m"
	local f_ref="\\\\e[01;36m"
	local f_bold="\\\\e[01;36m"
	local f_italic="\\\\e[41;37m"
	local f_underline="\\\\e[4;37m"
	local f_code="\\\\e[00m"
	local f_linklabel="\\\\e[01;31m"
	local f_linkurl="\\\\e[04m"
	local f_formatchrs="\\\\e[01;34m"

	# The characters "£, §" are used as metacharacters. They should not be encountered in a feed...
	local formated_feed="$(echo $rss_source | \
		sed -e 's/&amp;/\&/g
		s/&lt;\|&#60;/</g
		s/&gt;\|&#62;/>/g
		s/<\/a>/£/g
		s/href\=\"/§/g
		s/<title>/\\n\\n\\n   :: '$f_title'/g; s/<\/title>/\\e[00m ::\\n/g
		s/<link>/ [ '$f_ref'/g; s/<\/link>/\\e[00m ]/g
		s/<description>/\\n\\n'$f_descr'/g; s/<\/description>/\\e[00m\\n\\n/g
		s/<p\( [^>]*\)\?>\|<br\s*\/\?>/\n/g
		s/<b\( [^>]*\)\?>\|<strong\( [^>]*\)\?>/'$f_bold'/g; s/<\/b>\|<\/strong>/'$f_descr'/g
		s/<i\( [^>]*\)\?>\|<em\( [^>]*\)\?>/'$f_italic'/g; s/<\/i>\|<\/em>/'$f_descr'/g
		s/<u\( [^>]*\)\?>/'$f_underline'/g; s/<\/u>/'$f_descr'/g
		s/<code\( [^>]*\)\?>/'$f_code'/g; s/<\/code>/'$f_descr'/g
		s/<a[^§]*§\([^\"]*\)\"[^>]*>\([^£]*\)[^£]*£/'$f_linklabel'\2'$f_descr' '$f_formatchrs'['$f_descr' '$f_linkurl'\1'$f_descr''$f_formatchrs' ]'$f_descr'/g
		s/<li\( [^>]*\)\?>/\n '$f_formatchrs'*'$f_descr' /g
		s/<!\[CDATA\[\|\]\]>//g
		s/\|>\s*<//g
		s/ *<[^>]\+> */ /g
		s/[<>£§]//g')\n\n";
	echo -e "$formated_feed"
	# END OF THE RSS PARSER

	# Save latest header/date
	echo -e "$formated_feed" | grep -Fm1 org/news > $FEED_BOOKMARKS/latest

	# If bookmark name is provided, save it
	if [ -n "$2" ]; then
		echo "$1" > $FEED_BOOKMARKS/$2
		echo -e "\\n\\t\\e[01;37m==> \\e[01;31mBookmark saved as \\e[01;36m\\e[04m$2\\e[00m\\e[01;37m <==\\e[00m\\n"
	fi
}

deef() {
	if test -n "$1"; then
		if [ ! -r "$FEED_BOOKMARKS/$1" ]; then
			echo -e "\\n \\e[01;31mBookmark \\e[01;36m\\e[04m$1\\e[00m\\e[01;31m not found.\\e[00m\\n\\n \\e[04mType:\\e[00m\\n\\n   \\e[01;37m\$ deef\\e[00m (without arguments)\\n\\n to get the complete list of all currently saved bookmarks.\\n";
			return 1;
		fi
		local url="$(cat $FEED_BOOKMARKS/$1)";
		if [ ! -n "$url" ]; then
			echo "The bookmark is empty";
			return 1;
		fi
		echo -e "\\n\\t\\e[01;37m==> \\e[01;31m$url\\e[01;37m <==\\e[00m"
		feed "$url";
	else
		echo -e "\\n \\e[04mUsage\\e[00m\\n\\n   \\e[01;37m\$ deef \\e[01;31m<bookmark>\\e[00m\\n\\n \\e[04mCurrently saved bookmarks\\e[00m\\n";
		for i in $(find $FEED_BOOKMARKS -maxdepth 1 -type f);
			do echo -e "   \\e[01;36m\\e[04m$(basename $i)\\e[00m";
		done;
		echo -e "\\n \\e[04mSee also\\e[00m\\n\\n   \\e[01;37m\$ feed\\e[00m\\n";
	fi;
}
