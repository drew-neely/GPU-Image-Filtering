#ifndef FILTER_H
#define FILTER_H

#include <math.h>

#include "image.h"
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>


struct Filter {
	int iterations;

	Filter(int iterations) : iterations(iterations) {}
};


struct GausBlur : Filter {

	int radius;
	int size;
	// device_ptr<double> kernelDev;
	double* kernel;

	double kernelAt(double strength, int x, int y);

	__host__ __device__
	int getIndex(int x, int y);

	// strength = stdev in gaussian transformation equation
	// radius == -1 => choose the radius to make it such that an increase in
	//		radius of 1 sees an inclusion increase of < 1%
	GausBlur(double strength, int radius = -1);

	__host__
	Pixel transform(Pixel* data, int width, int height, int cx, int cy);


	__host__ __device__
	Pixel transform(device_ptr<Pixel> data, device_ptr<double> kernel, int width, int height, int cx, int cy);

};

struct Invert : Filter {

	Invert();

	__host__
	Pixel transform(Pixel* data, int width, int height, int cx, int cy);


	__host__ __device__
	Pixel transform(device_ptr<Pixel> data, int width, int height, int cx, int cy);

};


#endif