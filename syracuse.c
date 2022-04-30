#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv)
{
    //Return error if there are not enough or too many arguments
    if (argc != 3)
    {
        printf("\nUtilisation : syracuse <valeur_de_u0> <nom_du_fichier_sortie>\n\n<valeur_de_u0> est un entier strictement positif.\n<nom_du_fichier_sortie> ne necessite pas d'extension.\n");
        exit(1);
    }

    //Convert char (argv[1]) into a long (u0)
    long u0 = strtol(argv[1], NULL, 10);

    //Return error if u0 is below 0
    if (u0 <= 0)
    {
        printf("\nLe premier terme de la suite de Syracuse doit etre un entier strictement positif.\n");
        exit(1);
    }

    //Adding the extension and opening the DAT file.
    strcat(argv[2], ".dat");

    FILE *fichierSortie = fopen(argv[2], "w");

    //Initializing variables
    long element = u0, altimax = u0, dureevol = 0, dureealtitude = 0;
    int vol_en_altitude = 1;

    fprintf(fichierSortie, "n Un\n0 %ld\n", u0);

    while (element != 1)
    {
        dureevol++;

        //Calculation of the terms
        if (element % 2 == 0)
        {
            element = element / 2;
        }
        else
        {
            element = element * 3 + 1;
        }

        fprintf(fichierSortie, "%ld %ld\n", dureevol, element);

        //Calculation of the maximum altitude.
        if (element > altimax)
        {
            altimax = element;
        }

        //Calculation of flight duration at altitude.
        if (element < u0)
        {
            vol_en_altitude = 0;
        }

        if (vol_en_altitude)
        {
            dureealtitude++;
        }
    }

    fprintf(fichierSortie, "altimax=%ld\ndureevol=%ld\ndureealtitude=%ld", altimax, dureevol, dureealtitude);

    //Closing the file.
    fclose(fichierSortie);

    return 0;
}
