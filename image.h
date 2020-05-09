#ifndef IMAGE_H
#define IMAGE_H

#include <vector>
#include <iostream>
#include <assert.h>

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
	vector<Pixel> data;

	Pixel get(int x, int y) {
		assert(x < width && y < height && x >= 0 && y >= 0);
		return data[y * width + x];
	}
	
	void set(Pixel &p, int x, int y) {
		assert(x < width && y < height && x >= 0 && y >= 0);
		data[y * width + x] = p;
	}

	Image(unsigned int width, unsigned int height, vector<Pixel> data) :
			width(width), height(height), data(data) {};

	Image(unsigned int width, unsigned int height) :
			width(width), height(height), data(vector<Pixel>(width * height)) {};
};


namespace ImageIO {
	Image loadImage(char* filename);

	void writeImage(char* filename, Image &image);
};

#endif