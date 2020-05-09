#include <vector>
#include <iostream>

extern "C" {
    #define STB_IMAGE_IMPLEMENTATION
	#define STB_IMAGE_WRITE_IMPLEMENTATION
    #include "stb_image.h"
	#include "stb_image_write.h"
}

#include "image.h"

using namespace std;

Image ImageIO::loadImage(char* filename) {
	int width,height,n;
	unsigned char *data = stbi_load(filename, &width, &height, &n, 0);
	if(n != 3) {
		fprintf(stderr, "Image is weird - %d bytes per pixel\n", n);
		exit(1);
	}

	if (data != nullptr && width > 0 && height > 0)
	{
		auto image = vector<vector<Pixel>>(height);
		for(int y = 0; y < height; y++) {
			auto row = vector<Pixel>(width);
			for(int x = 0; x < width; x++) {
				int i = (width * y + x) * n;
				row[x].r = data[i];
				row[x].g = data[i + 1];
				row[x].b = data[i + 2];
				// printf("(%d, %d) -- <%d, %d, %d>\n", x, y,
				// 		data[i], data[i+1], data[i+2]);
			}
			image[y] = row;
		}
		stbi_image_free(data);

		// printf("%p %p %p\n", (int*)&image, (int*)&image[0], (int*)&image[0][0]);

		return Image(width, height, image);

	}
	else
	{
		fprintf(stderr, "Some error in loading in image\n");
		exit(1);
	}
}

void ImageIO::writeImage(char* filename, Image &image) {
	unsigned char data[image.width * image.height * 3];
	for(int y = 0; y < image.height; y++) {
		for(int x = 0; x < image.width; x++) {
			Pixel p = image.data[y][x];
			int i = (image.width * y + x) * 3;
			data[i  ] = p.r;
			data[i+1] = p.g;
			data[i+2] = p.b;
		}
	}
	stbi_write_jpg(filename, image.width, image.height, 3, data, 100);
}