
#include <stdio.h>
#include <iostream>
#include <string.h>
#include <typeinfo>
#include <stdlib.h>
#include <fstream>
#include <chrono> 

using namespace std;
using namespace chrono;

#include "flag_parsing.h"
#include "filter.h"
#include "image.h"
#include "apply.h"

int main(int argc, char* argv[]) {
	char* inImage;
	char* outImage;
	char* impl;
	char* filter;
	int radius;
	int strength;

	FLAG::get<char*>(argc, argv, "-in", &inImage, nullptr);
	FLAG::get<char*>(argc, argv, "-out", &outImage, nullptr);
	FLAG::get<char*>(argc, argv, "-impl", &impl, nullptr);
	FLAG::get<char*>(argc, argv, "-f", &filter, nullptr);
	FLAG::get<int>(argc, argv, "-r", &radius, -1);
	FLAG::get<int>(argc, argv, "-s", &strength, -1);

	if(inImage == nullptr) {
		fprintf(stderr, "No input specified\n");
		exit(1);
	} 
	if(outImage == nullptr) {
		fprintf(stderr, "No output specified\n");
		exit(1);
	}
	if(impl == nullptr) {
		fprintf(stderr, "No implementation specified\n");
		exit(1);
	}
	if(filter == nullptr) {
		fprintf(stderr, "No filter specified\n");
		exit(1);
	}

	// load Image
	Image image = ImageIO::loadImage(inImage);
	
	Image newImage;

	auto start = steady_clock::now();

	if(!strcmp(filter, "blur")) {
		if(strength == -1) {
			fprintf(stderr, "Radius not included for blur\n");
			exit(1);
		}
		GausBlur blur = GausBlur(strength, radius);
		if(!strcmp(impl, "seq")) {
			newImage = Apply::seq_blur(image, blur);
		} else if(!(strcmp(impl,"thrust"))) {
			newImage = Apply::thrust_blur(image, blur);
		}
	} else if(!strcmp(filter, "invert")) {
		Invert invert = Invert();
		if(!strcmp(impl, "seq")) {
			newImage = Apply::seq_invert(image, invert);
		} else if(!(strcmp(impl,"thrust"))) {
			newImage = Apply::thrust_invert(image, invert);
		}
	} else {
		fprintf(stderr, "Unknown filter \"%s\"\n", filter);
		exit(1);
	}

	auto end = chrono::steady_clock::now();
	printf("%ld milis\n", duration_cast<milliseconds>(end - start).count());

	ImageIO::writeImage(outImage, newImage);

}
