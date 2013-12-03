#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <math.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "reverse.h"


int main(int argc, char** argv){
        int numero_archivos = argc - 1;
        int archivo;
        bool noFile = false;
        if (numero_archivos == 0){
                archivo = 0; 
                numero_archivos = 1;
                noFile = true;
        }
        else if (strcmp(argv[1],"-h")==0 && (numero_archivos==1)){
                printf("Usage:\ntp1 -h\ntp1 -V\ntp1 [file...]\nOptions:\n-V, --version  Print version and quit.\n-h, --help  Print this information and quit.\nExamples:\nt10 foo.txt bar.txt\ntp1 gz.txt\ntp1 <stdin> \n ");
                return 0;              
                }
        else if (strcmp(argv[1],"-V")==0 && (numero_archivos==1)){
                printf("tp1 - 1 \n(66.20 Organizacion de Computadoras - FIUBA)\n2do cuatrimestre 2013.\nEscrito por  Mateo Bosco y Juan Manuel Hidalgo. \n");
                return 0;              
                }
        int i = 0;
        int resultado = 0;
        while (i < numero_archivos){
                if (! noFile){
                        archivo = open(argv[i+1],O_RDONLY);
                }
               
                if(archivo < 0){ // file < 0 es error
                        fprintf(stderr,"Ocurrio un error al abrir el archivo %s\n. El programa terminara ahora.",argv[i+1]);
                        exit(1);
                } else {
						resultado = reverse(archivo, 1);
                        close(archivo);
                        if(resultado != 0){
                                printf("%s\n",reverse_errmsg[resultado]);
                                return resultado;
                        }
                }
                i++;
        }
        printf("%s\n", reverse_errmsg[resultado]);
        return 0;
}
