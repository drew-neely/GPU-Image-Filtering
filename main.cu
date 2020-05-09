
#include <stdio.h>
#include <iostream>
#include <string.h>
#include <typeinfo>
#include <stdlib.h>
#include <fstream>
#include <chrono> 

using namespace std;

#include "flag_parsing.h"
#include "filter.h"
#include "image.h"
#include "apply.h"

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
		fprintf(stderr, "No output specified\n");
		exit(1);
	}

	Image image = ImageIO::loadImage(inImage);

	GausBlur blur = GausBlur(4);
	
	Image newImage = Apply::seq(image, blur);

	ImageIO::writeImage(outImage, newImage);

}