#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <math.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "reverse.h"


void invertir_Linea(char* linea,int largo){
    if (!linea) return;
    int i = 0;
    int j = largo-1;
    while (j > i){
                char aux = linea[i];
                linea[i]=linea[j];
                linea[j]=aux;
                i++;
                j--;
    }
   
}


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
                printf("Usage:\ntp0 -h\ntp0 -V\ntp0 [file...]\nOptions:\n-V, --version  Print version and quit.\n-h, --help  Print this information and quit.\nExamples:\ntp0 foo.txt bar.txt\ntp0 gz.txt\n");
                return 0;              
                }
        else if (strcmp(argv[1],"-V")==0 && (numero_archivos==1)){
                printf("Tp0 Version 1.0");
                return 0;              
                }
        //int fileout = open("salida.out",O_WRONLY);
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
                        //resultado=reverse(archivo, fileout);
						resultado = reverse(archivo, 1);
                        close(archivo);
                        if(resultado != 0){
                                printf("%s\n",errores[resultado]);
                                return resultado;
                        }
                }
                i++;
        }
        printf("%s\n", errores[resultado]);
        return 0;
}
