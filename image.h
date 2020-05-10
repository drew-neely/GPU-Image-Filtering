#ifndef IMAGE_H
#define IMAGE_H

#include <vector>
#include <iostream>
#include <assert.h>
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>

using namespace std;
using namespace thrust;

struct Pixel {
	unsigned char r;
	unsigned char g;
	unsigned char b;
	 
	__host__ __device__ Pixel() {}

	__host__ __device__ Pixel(unsigned char r, unsigned char g, unsigned char b) :
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
	host_vector<Pixel> data;
	device_vector<Pixel> deviceData;
	bool primaryIsHost;

	Pixel get(int x, int y) {
		assert(x < width && y < height && x >= 0 && y >= 0);
		if (primaryIsHost) {
			return data[y * width + x];
		} else {
			return deviceData[y * width + x];
		}
	}
	
	void set(Pixel &p, int x, int y) {
		assert(x < width && y < height && x >= 0 && y >= 0);
		if(primaryIsHost) {
			data[y * width + x] = p;
		} else {
			deviceData[y * width + x] = p;
		}
	}

	void moveToDevice() {
		deviceData = data;
		primaryIsHost = false;
	}

	void moveToHost() {
		data = deviceData;
		primaryIsHost = true;
	}

	Image() {};

	Image(unsigned int width, unsigned int height, vector<Pixel> data) :
			width(width), height(height), data(data), primaryIsHost(true) {};

	Image(unsigned int width, unsigned int height) :
			width(width), height(height), data(host_vector<Pixel>(width * height)),
			primaryIsHost(true) {};
};


namespace ImageIO {
	Image loadImage(char* filename);

	void writeImage(char* filename, Image &image);
};

#endif