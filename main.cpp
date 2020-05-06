
#include <stdio.h>
#include <iostream>
#include <string.h>
#include <typeinfo>
#include <stdlib.h>
#include <fstream>
#include <chrono> 


using namespace std;

#include "flag_parsing.h"

int main(int argc, char* argv[]) {
	char* inImage;
	char* outImage;

	FLAG::get<char*>(argc, argv, "-in", &inImage, nullptr);
	FLAG::get<char*>(argc, argv, "-out", &outImage, nullptr);

	if(inImage == nullptr) {
		fprintf(stderr, "No input specified\n");
		exit(1);
	} 
	if(outImage == nullptr) {
		
	}
}