#include <math.h>

#include "image.h"
#include "filter.h"
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>


double GausBlur::kernelAt(double strength, int x, int y) {
	return 1.0 / (2 * M_PI * strength * strength) *
		exp(-1.0 * (x*x + y*y) / (2.0 * strength * strength));
}

__host__ __device__
int GausBlur::getIndex(int x, int y) {
	return y * size + x;
}

// strength = stdev in gaussian transformation equation
// radius == -1 => choose the radius to make it such that an increase in
//		radius of 1 sees an inclusion increase of < 1%
GausBlur::GausBlur(double strength, int radius) : Filter(1) {
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
	printf("size %d\n", size);

	// host_vector<double> kernelHV = host_vector<double>(size*size);
	kernel = (double*) malloc(sizeof(double) * size * size);

	for(int y = 0; y <= radius; y++) {
		for(int x = 0; x <= radius; x++) {
			double val = kernelAt(strength, x, y);
			// kernelHV[getIndex(radius + y, radius + x)] = val;
			// kernelHV[getIndex(radius + y, radius - x)] = val;
			// kernelHV[getIndex(radius - y, radius + x)] = val;
			// kernelHV[getIndex(radius - y, radius - x)] = val;
			kernel[getIndex(radius + y, radius + x)] = val;
			kernel[getIndex(radius + y, radius - x)] = val;
			kernel[getIndex(radius - y, radius + x)] = val;
			kernel[getIndex(radius - y, radius - x)] = val;
		}
	}
	
	// this.kernel = (double*) kernelHV.data();
	// device_vector<double> kernelDV = kernelHV;
	// printf("size: %d\n", size);
	// printf("kernel[27] = %f\n",   (double)kernel[27]);
	// printf("kernelHV[27] = %f\n", (double)kernelHV[27]);
	// printf("kernelDV[27] = %f\n", (double)kernelDV[27]);
	// this.kernelDev = kernelDV.data();
	// printf("kernelDeV[27] = %f\n", (double)this.kernelDeV[27]);
	// printf("kernelDeV = %p\n", this.kernelDeV);

}

__host__
Pixel GausBlur::transform(Pixel* data, int width, int height, int cx, int cy) {
	// bool v = (cx == 100 && cy == 100) || (cx == 105 && cy == 100) || (cx == 100 && cy == 99); 
	// if(v) printf("(%d, %d)\n", cx, cy);
	double r = 0;
	double g = 0;
	double b = 0;
	double totalWeight = 0;
	for(int y = cy - radius; y < cy + radius + 1; y++) {
		for(int x = cx - radius; x < cx + radius + 1; x++) {
			if(y >= 0 && y < height && x >= 0 && x < width) {
				Pixel p = data[width * y + x];
				double k = kernel[getIndex(y - (cy - radius), x - (cx - radius))];
				// if(v) printf("(%d, %d) => %f\n", x, y, k);
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
	return newPixel;

}

__host__ __device__
Pixel GausBlur::transform(device_ptr<Pixel> data, device_ptr<double> kernel, int width, int height, int cx, int cy) {
	// bool v = (cx == 100 && cy == 100) || (cx == 105 && cy == 100) || (cx == 100 && cy == 99); 
	// if(v) printf("kernel = %p\n", (void*) kernel);
	// if(v) printf("(%d, %d)\n", cx, cy);
	double r = 0;
	double g = 0;
	double b = 0;
	double totalWeight = 0;
	for(int y = cy - radius; y < cy + radius + 1; y++) {
		for(int x = cx - radius; x < cx + radius + 1; x++) {
			if(y >= 0 && y < height && x >= 0 && x < width) {
				Pixel p = data[width * y + x];
				double k = kernel[getIndex(y - (cy - radius), x - (cx - radius))];
				// if(v) printf("(%d, %d) => %f\n", x, y, k);
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
	return newPixel;

}