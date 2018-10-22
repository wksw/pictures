#!/bin/bash


ROOTDIR=$(cd $(dirname $0); pwd)
PROCESS=${1:-100}

trap "exec 3>&-;exec 3<&-;exit 0" 2
[ -e $ROOTDIR/$$ ] || mkfifo $ROOTDIR/$$
exec 3<> $ROOTDIR/$$ 
rm -rf $ROOTDIR/$$ 
for i in $(seq $PROCESS)
do
	echo >&3
done
download()
{ 
	for classify in ${@}
	do
		html=$(curl -s -X GET "http://www.mm131.com/${classify}/" -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36' -H "Referer: http://www.mm131.com/$classify" --compressed| iconv -fgb2312 -t utf-8 )
		# 首页
		for i in $(echo $html | sed -r 's#.*<dl class="list-left public-box">(.*)末页.*#\1#'|sed -r 's#.*</dt>(.*)<dd class="page">.*#\1#'|grep href)
		do 
			
			for url in $(echo $i|grep href|awk -F '"' '{print $2}')
			do
				ID=$(echo ${url##*/} | awk -F '.' '{print $1}')
				if [ ! -d "$ROOTDIR/$classify/$ID" ];then
					mkdir -p $ROOTDIR/$classify/$ID
					page=$(curl -s -X GET $url | iconv -fgb2312 -t utf-8)
					total_page=$(echo $page|sed -r 's#.*共(.*)页.*#\1#' | awk -F '页' '{print $1}')
					for p in $(seq 1 $total_page)
					do
						read -u3
						{
							echo "download the ${classify}'s home page with ${ID} page $p"
							curl -s -o $ROOTDIR/$classify/${ID}/${p}.jpg "http://img1.mm131.me/pic/${ID}/${p}.jpg" -H "Referer: http://www.mm131.com/$classify/${ID}_${p}.html" -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36' --compressed
							echo >&3
						} &
					done
				fi
			done		
		done

		# 非首页
		pages_html=$(echo $html | sed -r 's#.*<dl class="list-left public-box">(.*)末页.*#\1#' |sed -r 's#.*</a><a href(.*).*#\1#' |awk -F "'" '{print $2}')
		pages_string=${pages_html%.*}
		for nt in $(seq 2 ${pages_string##*_})
		do
			echo $classify NEXT PAGE $nt
			html=$(curl -s -X GET "http://www.mm131.com/$classify/${pages_string%_*}_${nt}.html" -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36' -H "Referer: http://www.mm131.com/$classify/${pages_string%_*}_${nt}.html" --compressed| iconv -fgb2312 -t utf-8)
			for i in $(echo $html | sed -r 's#.*<dl class="list-left public-box">(.*)末页.*#\1#'|sed -r 's#.*</dt>(.*)<dd class="page">.*#\1#'|grep href)
			do 
				for url in $(echo $i|grep href|awk -F '"' '{print $2}')
				do
					ID=$(echo ${url##*/} | awk -F '.' '{print $1}')
					if [ ! -d "$ROOTDIR/$classify/$ID" ];then
						mkdir -p $ROOTDIR/$classify/$ID
						page=$(curl -s -X GET $url -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36' -H "Referer: $url" --compressed| iconv -fgb2312 -t utf-8)
						total_page=$(echo $page|sed -r 's#.*共(.*)页.*#\1#' | awk -F '页' '{print $1}')
						for p in $(seq 1 $total_page)
						do
							read -u3
							{
								echo "download the ${classify}'s page $nt with ${ID} page $p"
								curl -s -o $ROOTDIR/$classify/${ID}/${p}.jpg "http://img1.mm131.me/pic/${ID}/${p}.jpg" -H "Referer: http://www.mm131.com/$classify/${ID}_${p}.html" -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36' --compressed
								echo >&3
							}&
						done
					fi
				done
			done
		done
	done
	wait
}

download1() {
	html=$(curl -s 'http://www.mmjpg.com/' -H 'Connection: kve' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Referer: http://www.mmjpg.com/tag/xinggan' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7' --compressed)
	# 首页
	pre_line=
	for i in $(echo $html | sed -r 's#.*<div class="main">(.*)<div class="page">.*#\1#')
	do 
		for url in $(echo $i|grep 'href'|awk -F '"' '{print $2}') 
		do
			ID=$(echo ${url##*/} | awk -F '.' '{print $1}')
			if [ ! -d $ROOTDIR/mmjpg/$ID ];then
				mkdir -p $ROOTDIR/mmjpg/$ID
				page=$(curl -s $url -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Referer: http://www.mmjpg.com/' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7' --compressed)
				content=$(echo $page |sed -r 's#.*<div class="content"(.*)<div class="page".*#\1#' | sed -r 's#.*src(.*)data-img.*#\1#'|awk -F '"' '{print $2}')
				curl -s -o $ROOTDIR/mmjpg/$ID/1.jpg $content -H 'Referer: http://www.mmjpg.com/mm/1508' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36' --compressed
				total_page=$(echo $page |sed -r 's#.*<div class="page"(.*)<em class="ch all".*#\1#' |sed -r 's#.*>(.*)</a>#\1#')
				for p in $(seq 2 $total_page)
				do
					read -u3
					{
						echo "download the home page with ${ID} page $p"
						page=$(curl -s $url/$p -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Referer: http://www.mmjpg.com/' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7' --compressed)
						content=$(echo $page |sed -r 's#.*<div class="content"(.*)<div class="page".*#\1#' | sed -r 's#.*src(.*)data-img.*#\1#'|awk -F '"' '{print $2}')
						curl -s -o $ROOTDIR/mmjpg/$ID/${p}.jpg $content -H 'Referer: http://www.mmjpg.com/mm/1508' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36' --compressed
						echo >&3
					} &
				done
			fi
		done		
	done

	# 非首页
	pages_string=$(echo $html |sed -r 's#.*<div class="page"(.*)class="last".*#\1#' |sed -r 's#.*<a href(.*).*#\1#'|awk -F '"' '{print $2}')
	for nt in $(seq 2 ${pages_string##*/})
	do
		echo NEXT PAGE $nt
		html=$(curl -s "http://www.mmjpg.com/home/$nt" -H 'Connection: kve' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Referer: http://www.mmjpg.com/tag/xinggan' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7' --compressed)
		pre_line=
		for i in $(echo $html | sed -r 's#.*<div class="main">(.*)<div class="page">.*#\1#')
		do 
			for url in $(echo $i|grep 'href'|awk -F '"' '{print $2}') 
			do
				ID=$(echo ${url##*/} | awk -F '.' '{print $1}')
				if [ ! -d $ROOTDIR/mmjpg/$ID ];then
					mkdir -p $ROOTDIR/mmjpg/$ID
					page=$(curl -s $url -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Referer: http://www.mmjpg.com/' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7' --compressed)
					content=$(echo $page |sed -r 's#.*<div class="content"(.*)<div class="page".*#\1#' | sed -r 's#.*src(.*)data-img.*#\1#'|awk -F '"' '{print $2}')
					curl -s -o $ROOTDIR/mmjpg/$ID/1.jpg $content -H 'Referer: http://www.mmjpg.com/mm/1508' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36' --compressed
					total_page=$(echo $page |sed -r 's#.*<div class="page"(.*)<em class="ch all".*#\1#' |sed -r 's#.*>(.*)</a>#\1#')
					for p in $(seq 2 $total_page)
					do
						read -u3
						{
							echo "download the page $nt with ${ID} page $p"
							page=$(curl -s $url/$p -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Referer: http://www.mmjpg.com/' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7' --compressed)
							content=$(echo $page |sed -r 's#.*<div class="content"(.*)<div class="page".*#\1#' | sed -r 's#.*src(.*)data-img.*#\1#'|awk -F '"' '{print $2}')
							curl -s -o $ROOTDIR/mmjpg/$ID/${p}.jpg $content -H 'Referer: http://www.mmjpg.com/mm/1508' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36' --compressed
							echo >&3
						} &
					done
				fi
			done		
		done
	done
}

download2()
{
	for classify in ${@}
	do
		html=$(curl -s "http://www.the6688.com/$classify/" --compressed)
		for url in $(echo $html |sed -r 's#.*<div class="row">(.*)<div class="pages">.*#\1#'|grep href)
		do
			page=$(echo $url|grep href|awk -F '"' '{print $2}')
			if [ -n "$page" ];then
				name=$(echo ${page##*/}|awk -F '.' '{print $1}')
				if [ ! -d "$ROOTDIR/the6688/$classify/$name" ];then
					mkdir -p "$ROOTDIR/the6688/$classify/$name"
					page_html=$(curl -s $page)
					content=$(echo $page_html |sed -r 's#.*<section class="contes">(.*)</section>.*#\1#'|sed -r 's#.*src="(.+)" alt.*#\1#')
					curl -s -o $ROOTDIR/the6688/$classify/$name/1.jpg $content
					total_page=$(echo $page_html | sed -r 's#.*<div class="pages">(.*)下一页.*#\1#' |sed -r 's#.*>(.*)</a>.*#\1#')
					for i in $(seq 2 $total_page)
					do
						read -u3
						{
							echo "download the ${classify}'s home page with $name page $i"
							page_html=$(curl -s "http://www.the6688.com/$classify/${name}_${i}.html")
							content=$(echo $page_html |sed -r 's#.*<section class="contes">(.*)</section>.*#\1#'|sed -r 's#.*src="(.+)" alt.*#\1#')
							curl -s -o $ROOTDIR/the6688/$classify/$name/${i}.jpg $content
							echo >&3
						}&
					done
				fi
			fi
		done

		pages_string=$(echo $html | sed -r 's#.*<div class="pages">(.*)末页.*#\1#'|sed -r 's#.*href="(.*)" title.*#\1#')
		pages_name=$(echo ${pages_string##*/} |awk -F '.' '{print $1}')
		pages_prefix=${pages_name%_*}
		pages=${pages_name##*_}
		for nt in $(seq 2 $pages)
		do
			html=$(curl -s "http://www.the6688.com/$classify/${pages_prefix}_${nt}.html" --compressed)
			for url in $(echo $html |sed -r 's#.*<div class="row">(.*)<div class="pages">.*#\1#'|grep href)
			do
				page=$(echo $url|grep href|awk -F '"' '{print $2}')
				if [ -n "$page" ];then
					name=$(echo ${page##*/}|awk -F '.' '{print $1}')
					if [ ! -d "$ROOTDIR/the6688/$classify/$name" ];then
						mkdir -p "$ROOTDIR/the6688/$classify/$name"
						page_html=$(curl -s $page)
						content=$(echo $page_html |sed -r 's#.*<section class="contes">(.*)</section>.*#\1#'|sed -r 's#.*src="(.+)" alt.*#\1#')
						curl -s -o $ROOTDIR/the6688/$classify/$name/1.jpg $content
						total_page=$(echo $page_html | sed -r 's#.*<div class="pages">(.*)下一页.*#\1#' |sed -r 's#.*>(.*)</a>.*#\1#')
						for i in $(seq 2 $total_page)
						do
							read -u3
							{
								echo "download the ${classify}'s page $nt with $name page $i"
								page_html=$(curl -s "http://www.the6688.com/$classify/${name}_${i}.html")
								content=$(echo $page_html |sed -r 's#.*<section class="contes">(.*)</section>.*#\1#'|sed -r 's#.*src="(.+)" alt.*#\1#')
								curl -s -o $ROOTDIR/the6688/$classify/$name/${i}.jpg $content
								echo >&3
							}&
						done
					fi
				fi
			done
		done
	done
}

download3() {
	for classify in ${@}
	do
		html=$(curl -s https://www.duotoo.com/$classify/)
		for url in $(echo $html |sed -r 's#.*<div class="RightArticle" id="RightArticle">(.*)<div class="pages">.*#\1#'|grep href)
		do
			page=$(echo $url |grep href | awk -F '"' '{print $2}'|grep '.html')
			if [ -n "$page" ];then
				page_name=$(echo ${page##*/}|awk -F '.' '{print $1}')
				if [ ! -d "$ROOTDIR/duotoo/$classify/$page_name" ];then
					mkdir -p "$ROOTDIR/duotoo/$classify/$page_name"
					page_html=$(curl -s https://www.duotoo.com$page)
					content=$(echo $page_html |sed -r 's#.*<div class="ArticlePicBox Aid43 " id="ArticlePicBox TXid43">(.*)<div class="hr10"><script>.*#\1#' |sed -r 's#.*src(.*)</a>.*#\1#'|awk -F '"' '{print $2}')
					pic_url=$(curl -s $content|awk -F '"' '{print $2}')
					curl -s -o $ROOTDIR/duotoo/$classify/$page_name/1.jpg $pic_url
					total_page=$(echo $page_html |sed -r 's#.*共(.*)页:.*#\1#')
					for i in $(seq 2 $total_page)
					do
						read -u3
						{
							echo "download the ${classify}'s home page with $page_name page $i"
							page_html=$(curl -s "https://www.duotoo.com/${classify}/${page_name}_${i}.html")
							content=$(echo $page_html |sed -r 's#.*<div class="ArticlePicBox Aid43 " id="ArticlePicBox TXid43">(.*)<div class="hr10"><script>.*#\1#' |sed -r 's#.*src(.*)</a>.*#\1#'|awk -F '"' '{print $2}')
							pic_url=$(curl -s $content|awk -F '"' '{print $2}')
							curl -s -o $ROOTDIR/duotoo/$classify/$page_name/${i}.jpg $pic_url
							echo >&3
						}&
					done
				fi
			fi

		done
		page_string=$(echo $html |sed -r 's#.*href(.*)尾页.*#\1#')
		pages=$(echo $page_string|awk -F '.' '{print $1}'|awk -F '_' '{print $2}')
		for nt in $(seq 2 $pages)
		do
			html=$(curl -s https://www.duotoo.com/$classify/index_${nt}.html)
			for url in $(echo $html |sed -r 's#.*<div class="RightArticle" id="RightArticle">(.*)<div class="pages">.*#\1#'|grep href)
			do
				page=$(echo $url |grep href | awk -F '"' '{print $2}'|grep '.html')
				if [ -n "$page" ];then
					page_name=$(echo ${page##*/}|awk -F '.' '{print $1}')
					if [ ! -d "$ROOTDIR/duotoo/$classify/$page_name" ];then
						mkdir -p "$ROOTDIR/duotoo/$classify/$page_name"
						page_html=$(curl -s https://www.duotoo.com$page)
						content=$(echo $page_html |sed -r 's#.*<div class="ArticlePicBox Aid43 " id="ArticlePicBox TXid43">(.*)<div class="hr10"><script>.*#\1#' |sed -r 's#.*src(.*)</a>.*#\1#'|awk -F '"' '{print $2}')
						pic_url=$(curl -s $content|awk -F '"' '{print $2}')
						curl -s -o $ROOTDIR/duotoo/$classify/$page_name/1.jpg $pic_url
						total_page=$(echo $page_html |sed -r 's#.*共(.*)页:.*#\1#')
						for i in $(seq 2 $total_page)
						do
							read -u3
							{
								echo "download the ${classify}'s page $nt with $page_name page $i"
								page_html=$(curl -s "https://www.duotoo.com/${classify}/${page_name}_${i}.html")
								content=$(echo $page_html |sed -r 's#.*<div class="ArticlePicBox Aid43 " id="ArticlePicBox TXid43">(.*)<div class="hr10"><script>.*#\1#' |sed -r 's#.*src(.*)</a>.*#\1#'|awk -F '"' '{print $2}')
								pic_url=$(curl -s $content|awk -F '"' '{print $2}')
								curl -s -o $ROOTDIR/duotoo/$classify/$page_name/${i}.jpg $pic_url
								echo >&3
							}&
						done
					fi
				fi

			done
		done
	done
}

# download "qingchun"  &
# download "xiaohua" &
# download "chemo"  &
# download "qipao"   &
# download "mingxing"  &
# download "xinggan" &
# download1 &

# download2 "siwameinv" &
# download2 "guzhuangmeinv" &
# download2 "changtuimeinv" &
# download2 "sexmv" &
# download2 "rhmeinv" &
# download2 "gaoqing" &
# download2 "meitui" &
# download2 "mote" &
# download2 "xiaoqingxin" &
# download2 "mingxing" &
# download2 "top" &
# download2 "pingmian" &

download3 "xingganmeinv" "siwameinv" "meinvxiezhen" "rentiyishu" "qingchunmeinv" "jiepaimeinv" "changtuimeinv" "meinvmingxing" "neiyimeinv" "qingchunmeinv" &
wait
echo 3>&-
echo 3<&-
