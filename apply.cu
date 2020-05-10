#include "filter.h"
#include "image.h"
#include "apply.h"

#include <numeric>
#include <thrust/transform.h>
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>

using namespace std;
using namespace thrust;

Image Apply::seq_blur(Image &image, GausBlur &filter) {
	Image newImage(image.width, image.height);
	for(int y = 0; y < image.height; y++) {
		for(int x = 0; x < image.width; x++) {
			// bool v = (x == 100 && y == 100) || (x == 105 && y == 100) || (x == 100 && y == 99); 
			Pixel newPixel = filter.transform(image.data.data(), image.width, image.height, x, y);
			Pixel before = image.data[y*image.width+x];
			// if(v) printf("(%d, %d) : <%d, %d, %d> -> <%d, %d, %d>\n", 
				// x,y, before.r, before.g, before.b, newPixel.r, newPixel.g, newPixel.b);
			newImage.set(newPixel, x, y);
		}
	}
	return newImage;
}

struct BlurFunctor
{
    GausBlur filter;
	device_ptr<Pixel> dataptr;
	device_ptr<double> kernelptr;
	int width;
	int height;

    BlurFunctor(GausBlur &filter, device_ptr<Pixel> dataptr, int width, int height) : 
		filter(filter)
		, dataptr(dataptr)
		, width(width)
		, height(height)
		{
			int size = filter.size;
			device_vector<double> k(size*size);
			for(int i = 0; i < size*size; i++) {
				k[i] = filter.kernel[i];
			}
			kernelptr = k.data();
		}

    __host__ __device__
	Pixel operator()(const int &i) const {
		int x = i % width;
		int y = i / width;
		// bool v = (x == 100 && y == 100) || (x == 105 && y == 100) || (x == 100 && y == 99); 
		Pixel before = dataptr[y*width+x];
		Pixel after = ((GausBlur)filter).transform((device_ptr<Pixel>)dataptr,
			kernelptr,
			(int)width,
			(int)height,
			x,
			y);
		// if(v) printf("(%d, %d) : <%d, %d, %d> -> <%d, %d, %d>\n", 
			// x,y, before.r, before.g, before.b, after.r, after.g, after.b);
		return after;
	}
};

Image Apply::thrust_blur(Image &image, GausBlur &filter) {
	Image newImage(image.width, image.height);
	newImage.moveToDevice();
	image.moveToDevice();

	auto is = device_vector<int>(image.width * image.height);
	thrust::sequence(is.begin(), is.end());

	thrust::transform(
		is.begin(),
		is.end(), 
		newImage.deviceData.begin(),
		BlurFunctor(filter, image.deviceData.data(), image.width, image.height)
	);

	newImage.moveToHost();
	return newImage;
}


Image Apply::seq_invert(Image &image, Invert &filter) {
	Image newImage(image.width, image.height);
	for(int y = 0; y < image.height; y++) {
		for(int x = 0; x < image.width; x++) {
			Pixel newPixel = filter.transform(image.data.data(), image.width, image.height, x, y);
			Pixel before = image.data[y*image.width+x];
			newImage.set(newPixel, x, y);
		}
	}
	return newImage;
}

struct InvertFunctor
{
    Invert filter;
	device_ptr<Pixel> dataptr;
	int width;
	int height;

    InvertFunctor(Invert &filter, device_ptr<Pixel> dataptr, int width, int height) : 
		filter(filter)
		, dataptr(dataptr)
		, width(width)
		, height(height)
		{}

    __host__ __device__
	Pixel operator()(const int &i) const {
		int x = i % width;
		int y = i / width;
		Pixel before = dataptr[y*width+x];
		Pixel after = ((Invert)filter).transform((device_ptr<Pixel>)dataptr,
			(int)width,
			(int)height,
			x,
			y);
		return after;
	}
};

Image Apply::thrust_invert(Image &image, Invert &filter) {
	Image newImage(image.width, image.height);
	newImage.moveToDevice();
	image.moveToDevice();

	auto is = device_vector<int>(image.width * image.height);
	thrust::sequence(is.begin(), is.end());

	thrust::transform(
		is.begin(),
		is.end(), 
		newImage.deviceData.begin(),
		InvertFunctor(filter, image.deviceData.data(), image.width, image.height)
	);

	newImage.moveToHost();
	return newImage;
};

// Template instantiations since main uses these from a different obj file

// template Image Apply::seq<GausBlur>(Image &image, GausBlur &filter);
// template Image Apply::thrust<GausBlur>(Image &image, GausBlur &filter);