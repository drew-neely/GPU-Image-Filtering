#ifndef APPLY_H
#define APPLY_H

#include "image.h"
#include "filter.h"

namespace Apply {

	Image seq(Image &image, Filter &filter) {
		Image newImage(image.width, image.height);
		for(int y = 0; y < image.height; y++) {
			for(int x = 0; x < image.width; x++) {
				newImage.data[y][x] = filter.transform(image, x, y);
			}
		}
		return newImage;
	}

	Image thrust(Image &image, Filter &filter) {
		// TODO : do work
		return image;
	}

}

#endif