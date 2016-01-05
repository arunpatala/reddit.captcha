for i in {1..5}
do
	mkdir data/$i
	for j in {1..100}
	do
		 wget -o data/$i/$j.png --no-cookies --header "Cookie: reddit_session=2134300%2C2016-01-03T21%3A27%3A36%abcdef" https://www.reddit.com/captcha/$i.png
		 sleep 0.1
	done
done
