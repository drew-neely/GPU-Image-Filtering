#include <math.h>

#include "image.h"
#include "filter.h"
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>


Invert::Invert() : Filter(1) {};

__host__
Pixel Invert::transform(Pixel* data, int width, int height, int cx, int cy) {
	int i = cy * width + cx;
	Pixel old = data[i];
	return Pixel(255 - old.r, 255 - old.g, 255 - old.b);
};


__host__ __device__
Pixel Invert::transform(device_ptr<Pixel> data, int width, int height, int cx, int cy) {
	int i = cy * width + cx;
	Pixel old = data[i];
	return Pixel(255 - old.r, 255 - old.g, 255 - old.b);
};
