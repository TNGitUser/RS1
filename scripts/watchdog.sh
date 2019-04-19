#!/bin/sh

MAIL_TEMPLATE=/etc/scripts/.mail.template
MAIL_OUTPUT=/etc/scripts/.mail_output
TIME=`date +"%r / %Y-%m-%d : "`

# Checksum's save location
MD5loc=/etc/scripts/.md5save
TARGET=/etc/crontab


if [ ! -f $TARGET ]
then
	cp $MAIL_TEMPLATE $MAIL_OUTPUT
	sed -i -e 's@%title@CRITICAL:@g' $MAIL_OUTPUT
	sed -i -e "s@%subtitle@$TARGET missing!@g" $MAIL_OUTPUT
	sed -i -e "s@%time@$TIME@g" $MAIL_OUTPUT
	sed -i -e "s@%text@$TARGET is missing! Is it advised to quickly\
 resolve this problem.@g" $MAIL_OUTPUT
	sendmail root < $MAIL_OUTPUT
	rm $MAIL_OUTPUT
	exit 1
fi

if [ ! -f $MD5loc ]
then
	MD5SUMCHECK=`md5sum $TARGET | cut -d " " -f1`
	echo $MD5SUMCHECK > $MD5loc
	cp $MAIL_TEMPLATE $MAIL_OUTPUT
	sed -i -e 's/%title/IMPORTANT:/g' $MAIL_OUTPUT
	sed -i -e 's/%subtitle/Crontab file modifed!/g' $MAIL_OUTPUT
	sed -i -e "s@%time@$TIME@g" $MAIL_OUTPUT
	sed -i -e "s/%text/This mail has been sent because there is no\
 md5checksum thus the lack of information.\nA new md5checksum has been\
 generated. Be cautious if you're not the one that modified the\
 file./g" $MAIL_OUTPUT
	sendmail root < $MAIL_OUTPUT
	rm $MAIL_OUTPUT
else
	MD5SUMCHECK=`cat $MD5loc`
fi

MD5SUM=`md5sum $TARGET | cut -d " " -f1`

if [ "$MD5SUM" = "$MD5SUMCHECK" ]
then
	exit 1
else
	cp $MAIL_TEMPLATE $MAIL_OUTPUT
	sed -i -e 's/%title/IMPORTANT:/g' $MAIL_OUTPUT
	sed -i -e 's/%subtitle/Crontab file modifed!/g' $MAIL_OUTPUT
	sed -i -e "s@%time@$TIME@g" $MAIL_OUTPUT
	sed -i -e "s@%text@The file <$TARGET> has been modified.If this\
 modification was not scheduled, it is advised to take approriate actions.@g"\
 $MAIL_OUTPUT
	sendmail root < $MAIL_OUTPUT
	rm $MAIL_OUTPUT
	MD5SUMCHECK=`md5sum $TARGET | cut -d " " -f1`
	echo $MD5SUMCHECK > $MD5loc
	exit 1
fi

exit 1
