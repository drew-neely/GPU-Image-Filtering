#ifndef IMAGE_H
#define IMAGE_H

#include <vector>
#include <iostream>

using namespace std;

struct Pixel {
	unsigned char r;
	unsigned char g;
	unsigned char b;
	
	Pixel() {}

	Pixel(unsigned char r, unsigned char g, unsigned char b) :
			r(r), g(g), b(b) {};

	char* toString() {
		char* str = new char[16];
		sprintf(str, "<%d, %d, %d>", r, g, b);
		return str;
	}
};

struct Image {
	unsigned int width;
	unsigned int height;
	vector<vector<Pixel>> data;
	Image(unsigned int width, unsigned int height, vector<vector<Pixel>> data) :
			width(width), height(height), data(data) {};
	Image(unsigned int width, unsigned int height) :
			width(width), height(height) {
		data = vector<vector<Pixel>>(height);
		for(int i = 0; i < height; i++) {
			data[i] = vector<Pixel>(width);
		}
	};
};


namespace ImageIO {
	Image loadImage(char* filename);

	void writeImage(char* filename, Image &image);
};

#endif