#include "reverse.h"
/*
 * Checks the option passed via attribute. Prints a different output
 * depending on the option that was passed. Handles only one option
 * at a time.
 * 
 * attr: The string with the option received.
 */ 
int checkOption(char* attr) {
	
	// Match version option.
	if( !strcmp(attr, "-v") || !strcmp(attr, "--version") ) {
		printf("Version 1.0.0\n");
		return 1;
	}
	// Match help option.
	else if ( !strcmp(attr, "-h") || !strcmp(attr, "--help") ) {
		printf("Usage\n");
		return 1;
	}
	
	return 0;
	
}
/*
 * Makes a swap in the given string. The positions swapped are pos1
 * and pos2.
 * 
 * string: The string whose characters the function will swap.
 * pos1: First position in the string to swap.
 * pos2: Second position in the string to swap.
 */
void swapChars(char* string, int pos1, int pos2) {
	
	if( pos1 == pos2 ) return;
	
	char aux = string[pos2];
	string[pos2] = string[pos1];
	string[pos1] = aux;
	
}

/*
 * Copies the source string in a new space of memory and reverses
 * this copy. Returns the copy's reference.
 * 
 * source: The string to reverse.
 */
char* reverseString(charWrap* source) {
	unsigned len = source -> length;
	
	// One more character for \0 terminator.
	char* reversed = (char*) malloc( (len + 1) * sizeof(char) );
	strncpy(reversed, source -> string, len);
	
	int posInitial = 0;
	// Start counting from 0, so length - 1. One less for \n.
	int posFinal = len - 2;
	
	while( posInitial < posFinal )
		swapChars(reversed, posInitial++, posFinal--);

	reversed[len] = '\0';
		
	return reversed;
}

/*
 * Reads a line from the given filePtr. If the line is empty,
 * returns NULL. If the line is not empty, returns a reference
 * to the string. reference must be freed after.
 * 
 * filePtr: filePtr to be read.
 */
charWrap* readFromFile(FILE* filePtr) {
	
	// Initial buffer length.
	unsigned bufferLength = 30;
	// Allocate memory for buffer length and \0 terminator.
	char* finalString = (char*) malloc( (bufferLength + 2) * sizeof(char) );
	// Memory alloc error handling.
	if( finalString == NULL ) {
		fprintf(stderr, "Error: unable to allocate %d bytes on line 88\n", (bufferLength + 2) * sizeof(char) );
		return NULL;
	}
	
	// Initialize aux variables.
	char* auxString = NULL;
	int character = 0;
	int length = 0;
	
	// Parse stdin until we get \n (should be EOF).
	character = fgetc(filePtr);
	while( !feof(filePtr) ) {	
		length++;
		// Buffer has been filled. Allocate more memory.
		if( (length + 1) == bufferLength ) {
			bufferLength =  2 * bufferLength;
			auxString = (char*) realloc( finalString, bufferLength * sizeof(char) );
			// Memory alloc error handling.
			if( auxString == NULL ) {
				fprintf(stderr, "Error: unable to allocate %d bytes on line 107\n", bufferLength * sizeof(char) );
				free(finalString);
				return NULL;
			}
			finalString = auxString;
		}
		finalString[length-1] = character;
		if( character == '\n' ) break;
		character = fgetc(filePtr);
	}
	
	if( length == 0 ) {
		free(finalString);
		return NULL;
	}
	
	auxString = (char*) realloc( finalString, length * sizeof(char) );
	// Memory alloc error handling.
	if( auxString == NULL ) {
		fprintf(stderr, "Error: unable to allocate %d bytes on line 126", bufferLength * sizeof(char) );
		return NULL;
	}
	charWrap* retVal = (charWrap*) malloc( sizeof(charWrap) );
	if( retVal == NULL ) {
		fprintf(stderr, "Error: unable to allocate %d bytes on line 132", sizeof(charWrap) );
		return NULL;
	}
	retVal -> string = auxString;
	retVal -> length = length;
	return retVal;
}

/*
 * Prints the output of the given file after its lines were
 * reversed. File pointer must be already opened for reading
 * and must be closed after this call.
 * 
 * fPtr: file to be reversed.
 */
void reverseFile(FILE* fPtr) {
	
	char* reversed = NULL;
	charWrap* fileString = readFromFile(fPtr);
	
	while( fileString != NULL ) {
		reversed = reverseString(fileString);
		printf("%s", reversed);
		free(fileString -> string);
		free(fileString);
		free(reversed);
		fileString = readFromFile(fPtr);
	}
	
}

