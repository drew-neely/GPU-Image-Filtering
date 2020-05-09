#include "filter.h"
#include "image.h"
#include "apply.h"


Image Apply::seq(Image &image, Filter &filter) {
	Image newImage(image.width, image.height);
	for(int y = 0; y < image.height; y++) {
		for(int x = 0; x < image.width; x++) {
			Pixel newPixel = filter.transform(image, x, y);
			newImage.set(newPixel, x, y);
		}
	}
	return newImage;
}

Image Apply::thrust(Image &image, Filter &filter) {
	
	return image;
}