#ifndef APPLY_H
#define APPLY_H

namespace Apply {

	Image seq_blur(Image &image, GausBlur &filter);

	Image thrust_blur(Image &image, GausBlur &filter);

	Image seq_invert(Image &image, Invert &filter);

	Image thrust_invert(Image &image, Invert &filter);

}

#endif