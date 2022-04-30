#!/bin/bash

SECONDS=0

#FUNCTIONS

########################

#Analyzing ".dat" files to process data with gnuplot.
ecriture_data(){
    mkdir -p temp/flights

    for (( i=$1; i<=$2; i++ )); do
        nbLignes=$(wc -l < f$i.dat)
        (( n_max = $nbLignes - 3 ))
        tail -n$nbLignes f$i.dat | head -n$n_max > temp/flights/flight_$i.dat
    done

    for (( i=$1; i<=$2; i++ )); do
        echo "$i `grep altimax f$i.dat | cut -c9-` `grep dureevol f$i.dat | cut -c10-` `grep dureealtitude f$i.dat | cut -c15-`" >> temp/dataTemp.dat
    done
}

#Configuration of the graph "Un en fonction de n".
graph0_vols(){
    echo "set terminal jpeg" > temp/gnuplot_script
    echo "set output 'graphs/graph0_vols.jpg'" >> temp/gnuplot_script
    echo "set title 'Un en fonction de n pour tous les U0 dans [$1;$2]'" >> temp/gnuplot_script
    echo "set xlabel 'n'" >> temp/gnuplot_script
    echo "set ylabel 'Un'" >> temp/gnuplot_script

    echo -n "plot 'temp/flights/flight_$1.dat' title 'vols.dat' w l" >> temp/gnuplot_script
    for (( i=$1+1; i<=$2; i++ )); do
        echo -n ", 'temp/flights/flight_$i.dat' notitle w l lc 1" >> temp/gnuplot_script
    done
}

#Configuration of the graph "Altitude maximum en fonction de U0".
graph1_altitude(){
    echo -e "\nset terminal jpeg" >> temp/gnuplot_script
    echo "set output 'graphs/graph1_altitude.jpg'" >> temp/gnuplot_script
    echo "set title 'Altitude maximum atteinte en fonction de U0'" >> temp/gnuplot_script
    echo "set xlabel 'U0'" >> temp/gnuplot_script
    echo "set ylabel 'Altitude maximum'" >> temp/gnuplot_script

    echo "plot 'temp/dataTemp.dat' u 1:2 title 'altitude.dat' w l" >> temp/gnuplot_script
}

#Configuration of the graph "Durée de vol en fonction de U0".
graph2_dureevol(){
    echo "set terminal jpeg" >> temp/gnuplot_script
    echo "set output 'graphs/graph2_dureevol.jpg'" >> temp/gnuplot_script
    echo "set title 'Duree de vol en fonction de U0'" >> temp/gnuplot_script
    echo "set xlabel 'U0'" >> temp/gnuplot_script
    echo "set ylabel 'Nombre d''occurences'" >> temp/gnuplot_script

    echo "plot 'temp/dataTemp.dat' u 1:3 title 'dureevol.dat' w l" >> temp/gnuplot_script
}

#Configuration of the graph "Durée de vol en altitude en fonction de U0".
graph3_dureealtitude(){
    echo "set terminal jpeg" >> temp/gnuplot_script
    echo "set output 'graphs/graph3_dureealtitude.jpg'" >> temp/gnuplot_script
    echo "set title 'Duree de vol en altitude en fonction de U0'" >> temp/gnuplot_script
    echo "set xlabel 'U0'" >> temp/gnuplot_script
    echo "set ylabel 'Nombre d''occurences'" >> temp/gnuplot_script

    echo "plot 'temp/dataTemp.dat' u 1:4 title 'dureealtitude.dat' w l" >> temp/gnuplot_script
}

#Help Message
aide()
{
    echo -e "Usage:\n  ./syracuse.bash <u0_min> <u0_max>"
    echo -e "\nCalculates datas of the Syracuse sequence for each values between <u0_min> and <u0_max>.\n"
    echo "Options:"
    echo "  <u0_min>       minimal value of U0 in the range; has to be a positive integer"
    echo "  <u0_max>       maximum value of U0 in the range; has to be a higher positive integer than <u0_min>"
}

#Displays the help message when the option '-h' option is selected
while getopts ":h" opt; do
   case $opt in
      h) aide; exit;;
   esac
done

#The program displays an error message if the arguments are incorrect
if [ $# -ne 2 ] || [ $1 -le 0 ] || [ $1 -ge $2 ]; then
    echo -e "./syracuse.bash: usage error.\nTry './syracuse.bash -h' for more information."
    exit;
fi

#Folder where graphs are stored
if [ -d "graphs" ]; then
    echo -n "Do you want to delete the graphs previously generated? [Y/n] "
    read yn
    case $yn in
    y | Y ) echo "Deletion. "; rm -r graphs;;
    * ) echo "Abort."; exit;;
    esac
fi
mkdir graphs    

########################


#PROGRAM
       

#Built and run of the C code syracuse.c
echo -n "Generating data files... "
gcc syracuse.c -o syracuse
for (( i=$1; i<=$2; i++ )); do
    ./syracuse $i f$i
done
echo "Done"

#GNUplot setup and data transfer
echo -n "Analyzing datas... "
ecriture_data $1 $2
echo -e "Done\nBuilding graphs."
graph0_vols $1 $2
graph1_altitude $1 $2
graph2_dureevol $1 $2
graph3_dureealtitude $1 $2

#Run script GNUplot
gnuplot temp/gnuplot_script

#Deletion of temporary files
echo -n "Deleting temporary files... "
rm -r temp
rm syracuse
for (( i=$1; i<=$2; i++ )); do
    rm f$i.dat
done
echo "Done"

#Show the progress of the program

echo -e "\nThe following files have been saved:\n\n`ls --color graphs`\n\nFind your results in '/graphs' directory."
ELAPSED="$(($SECONDS % 60))"
echo "The program executed in ${ELAPSED} second(s)"
