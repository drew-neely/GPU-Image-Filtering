#ifndef FILTER_H
#define FILTER_H

#include <math.h>

#include "image.h"


struct Filter {
	int iterations;
	virtual Pixel transform(Image &image, int x, int y) {
		fprintf(stderr, "Called transform on Filter - should be overwritten");
		exit(1);
	};

	Filter(int iterations) : iterations(iterations) {}
};

struct GausBlur : public Filter {

	int radius;
	int size;
	double** kernel;

	double kernelAt(double strength, int x, int y) {
		return 1.0 / (2 * M_PI * strength * strength) *
			exp(-1.0 * (x*x + y*y) / (2.0 * strength * strength));
	}

	// strength = stdev in gaussian transformation equation
	// radius == -1 => choose the radius to make it such that an increase in
	//		radius of 1 sees an inclusion increase of < 1%
	GausBlur(double strength, int radius = -1) : Filter(1) {
		
		if(radius == -1) {
			double loss;
			do {
				radius++;
				loss = 0;
				for(int i = 1; i < radius; i++) {
					loss += kernelAt(strength, i, radius) * 8;
				}
				loss += kernelAt(strength, radius, 0) * 4;
				loss += kernelAt(strength, radius, radius) * 4;
			} while(loss > 0.01);
			radius --;
			this->radius = radius;
			this->size = radius * 2 + 1;
		} else {
			this->radius = radius;
			this->size = radius * 2 + 1;
		}
		kernel = (double**) malloc(sizeof(double*) * size);

		for(int i = 0; i < size; i++) {
			kernel[i] = (double*) malloc(sizeof(double) * size);
		}

		for(int y = 0; y <= radius; y++) {
			for(int x = 0; x <= radius; x++) {
				double val = kernelAt(strength, x, y);
				kernel[radius + y][radius + x] = val;
				kernel[radius + y][radius - x] = val;
				kernel[radius - y][radius + x] = val;
				kernel[radius - y][radius - x] = val;
			}
		}

		// for(int y = 0; y < size; y++) {
		// 	for(int x = 0; x < size; x++) {
		// 		printf("%.4f ", kernel[y][x]);
		// 	}
		// 	printf("\n");
		// }

	}

	virtual Pixel transform(Image &image, int cx, int cy) {
		double r = 0;
		double g = 0;
		double b = 0;
		double totalWeight = 0;
		for(int y = cy - radius; y < cy + radius + 1; y++) {
			for(int x = cx - radius; x < cx + radius + 1; x++) {
				if(y >= 0 && y < image.height && x >= 0 && x < image.width) {
					Pixel p = image.data[y][x];
					double k = kernel[y - (cy - radius)][x - (cx - radius)];
					// printf("\tk = %f\n", k);
					r += p.r * k;
					g += p.g * k;
					b += p.b * k;
					totalWeight += k;
				}
			}
		}
		r /= totalWeight; // scale for edges and rounded kernel
		g /= totalWeight;
		b /= totalWeight;
		Pixel newPixel = Pixel(round(r), round(g), round(b));
		Pixel f = image.data[cy][cx];
		return newPixel;

	}

};


#endif