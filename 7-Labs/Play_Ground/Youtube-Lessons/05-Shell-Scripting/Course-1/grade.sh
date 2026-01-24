#! /bin/bash

echo "Enter you score ( 0-100 )  "
read score

if [ $score -ge 90 ] && [ $score -le 100 ]; then
	echo "Your grade is an A"
elif [ $score -ge 80 ] && [ $score -lt 90 ]; then
	echo "Your grade is an B"
elif [ $score -ge 70 ] && [ $score -lt 80 ]; then
	echo "Your grade is an C"
elif [ $score -ge 60 ] && [ $score -lt 70 ]; then
	echo "Your grade is an D"
else 
	echo "Your grade is an E and you failed asshole !!!"
fi
