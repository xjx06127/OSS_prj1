#! /bin/bash
echo "---------------------------"
echo "User Name: choihongseok"
echo "Student Number: 12223832"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item'"
echo "3. Get the average 'rating' of the movide identified by specific 'movie id' from 'u.data'"
echo "4. Delete the 'IMDb URL' from 'u.item'"
echo "5. Get the data about users from 'u.user'"
echo "6. Modify the format of 'release date' in 'u.item'"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "---------------------------"

read -p  "Enter your choice [ 1-9 ] " choice
while true 
do
case $choice in
  1) echo "" 
read -p "Plase enter 'movie id'(1~1682):" id
echo ""
cat $1 | awk -v _id="$id" -F\| '$1==_id{print}';;

2) echo ""
read -p "Do you want to get the data of 'action' genre movies from 'u.item'?(y/n):" ans
if [ $ans = "y" ]
then
	echo ""
	cat $1 | awk -F\| '$7=="1"{print $1,$2}' | head -n 10 	
fi	
;;

3) echo ""
read -p "Plase enter the 'movie id'(1~1682):" id
echo ""
avg=0.0
cnt=0.0
cat $2 | awk -v _avg="$avg" -v _id="$id" -v _cnt="$cnt" '$2==_id{_avg+=$3;  _cnt+=1} END {printf("average rating of %s: %.5f\n",_id,_avg/_cnt)}';;

4) echo ""
read -p "Do you want to delete the 'IMDb URL' from 'u.item'?(y/n):" ans

if [ $ans = "y" ]
then
        echo ""
	cat $1 | sed -E 's/h[^|]*\|/\|/g' | head -n 10
fi
;;

5) echo ""
 read -p "Do you want to get the data about users from 'u.user'?(y/n):" ans

if [ $ans = "y" ]
then
        echo ""
        cat $3 | sed -E -e 's/([^|]+)\|([^|]+)\|M\|([^|]+).*/user \1 is \2 years old male \3/' -e  's/([^|]+)\|([^|]+)\|F\|([^|]+).*/user \1 is \2 years old female \3/' | head -n 10
fi
;;

6) echo ""
read -p "Do you want to Modify the format of 'release data' in 'u.item'?(y/n):" ans

if [ $ans = "y" ]
then
        echo ""
        cat $1 | sed -n '1673,1682p' |sed -E 's/([0-9]+)-Jan-([0-9]+)/\201\1/g' | sed -E 's/([0-9]+)-Feb-([0-9]+)/\202\1/g' | sed -E 's/([0-9]+)-Mar-([0-9]+)/\203\1/g' | sed -E 's/([0-9]+)-Apr-([0-9]+)/\204\1/g' | sed -E 's/([0-9]+)-May-([0-9]+)/\205\1/g' | sed -E 's/([0-9]+)-Jun-([0-9]+)/\206\1/g' | sed -E 's/([0-9]+)-Jul-([0-9]+)/\207\1/g' | sed -E 's/([0-9]+)-Aug-([0-9]+)/\208\1/g' | sed -E 's/([0-9]+)-Sep-([0-9]+)/\209\1/g' | sed -E 's/([0-9]+)-Oct-([0-9]+)/\210\1/g' | sed -E 's/([0-9]+)-Nov-([0-9]+)/\211\1/g' | sed -E 's/([0-9]+)-Dec-([0-9]+)/\212\1/g' 
fi
;;

7) echo ""
read -p "Plase enter the 'user id'(1~943):" id
data=$(cat $2| sort -k2n | awk -v _id="$id" '$1==_id{printf("%s|",$2)}' | sed 's/.$//')
echo ""
echo "$data"
echo ""

IFS="|" read -a array <<< "$data"

for ((i=0; i<10; i++)) 
do
	cat $1 | awk -v _id="${array[i]}" -F\| '$1==_id{printf("%s|%s\n",$1,$2)}' 
done

;;

8) echo ""
read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n):" ans
if [ $ans = "y" ]
then
        echo ""
	user_id=$(cat $3 | awk -F\| '($2<=29 && $2>=20) && ($4=="programmer") {printf("%s ",$1) }' | sed 's/.$//')

	IFS=" " read -a array_user_id <<< "$user_id"	

	rating_array=()
	rating_count_array=()
	for ((i=0; i<1683; i++))
	do
		rating_array[$i]=0
		rating_count_array[$i]=0
	done

	for id in "${array_user_id[@]}"
	do
		result=$(cat $2 | awk -v _id="$id" '$1==_id{ print $2, $3 }') 
		while read mid rating
		do
			rating_array["$mid"]=$((rating_array["$mid"] + rating))
			rating_count_array["$mid"]=$((rating_count_array["$mid"] + 1))
		done <<< "$result"
	done 

	for ((idx=1; idx<1683; idx++)) 
	do
		count=${rating_count_array[$idx]}
		if [ "$count" != "0" ]
		then
			ret=$(echo "scale=6; ${rating_array[$idx]} / $count" | bc)
			printf "%s %.5f\n" "$idx" "$ret" | sed -e 's/\.\([0-9]*[1-9]\)0*/.\1/g' -e 's/.00000//g' 			
		fi
	done
			 	
fi
;;

9) echo "Bye!"
exit 1
;;

*) echo "Invalid"
;;
 

 
esac
echo ""
read -p  "Enter your choice [ 1-9 ] " choice
done
