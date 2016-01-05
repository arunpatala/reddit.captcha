for i in {40..1000}
do
	for j in {1..100}
	do
		 wget --no-cookies --header "Cookie: reddit_session=2134300%2C2016-01-03T21%3A27%3A36%2C78a9f62870591eb7668f813f1db11484ed0f4c8a" https://www.reddit.com/captcha/$i.png
		 sleep 0.1
	done
done
