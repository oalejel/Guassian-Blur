/*
  Guassian Blur, by Omar Al-Ejel
 
 Guassian blur's are best performed with a horizontal, followed by a vertical pass
 over the image to compute two single-dimensional gaussian matrices.
 
 Checkpoints:
 - get basic image to show up on screen, and press enter to export to some location
 - write something that modifies every pixel with some function as a proof of concept
 
 - write the horizontal and vertical passes
 - debug until you have what seems to be a guassian blur
 
 
 - read user's numerical input to get standard deviation to be applied to gaussian blur
 - add some slider to modify the gaussian blur live, and then press enter to export 
 */

import java.lang.Math;

void setup() {
  size(500, 500);
  background(0);
  PImage img;
  img = loadImage("colors.png");

  ///// ---- will be placed in draw() later -------

  /*
  // proof that we should extract components during convolution process 
   color x = color(110, 11, 244);
   x *= 2;
   println(blue(x));
   */

  performBlur(img, 0.1);
  image(img, 0, 0);
}

void draw() {
}

double G(double x, double stdev) {
  // we are working with the normal distribution
  // I think that changing the filter's standard deviation does 
  // not mean changing the range of z scores we select from. we are directly
  // modifying the bell curve we are interested in applying to our kernel
  double out = 1 / Math.sqrt(2 * Math.PI * stdev * stdev);
  double exponent = -1 * Math.pow(x, 2) / (2 * stdev * stdev);
  double e = Math.exp(exponent);
  return e * out;
}

void performBlur(PImage img, double stdev) {
  // seems to prepare pixels of the foreground for access
  loadPixels();
  // seems to prepare image pixels for access
  img.loadPixels();

  // compute the kernels:
  // twice the width, so that the left-most pixel can relate to the right-most pixel
  int kernelXLength = img.width * 2;
  int kernelYLength = img.height * 2;
  double kernelX[] = new double[kernelXLength];
  double kernelY[] = new double[kernelYLength];

  // fill the kernel by scaling our indices to go from -sigma to +sigma

  // might need a sum we are working with discrete values 
  // that will overestimate area under normal distr
  double kernelXSum = 0;  
  for (int i = 0; i < kernelXLength; i++) {
    // fraction of stdev = (i - halfwidth) / halfwidth = (i / halfwidth) - 1
    double sigmaFraction = (i / (kernelXLength * 0.5)) - 1;
    double x = sigmaFraction;
    kernelX[i] = G(x, stdev);  
    print(x);
    print(", ");
    println(kernelX[i]);
    //println(x + ", " + kernelX[i]);
    kernelXSum += kernelX[i];
    //println(kernelX[i]);
  }

  // make sum = 1
  for (int i = 0; i < kernelXLength; i++) {
    kernelX[i] /= kernelXSum;
  }

  double kernelYSum = 0;  
  for (int i = 0; i < kernelYLength; i++) {
    // fraction of stdev = (i - halfwidth) / halfwidth = (i / halfwidth) - 1
    double sigmaFraction = ((double)i / (kernelYLength * 0.5)) - 1;
    double y = sigmaFraction;
    kernelY[i] = G(y, stdev);  
    kernelYSum += kernelY[i];
    //println(kernelY[i]);
  }

  for (int i = 0; i < kernelYLength; i++) {
    kernelY[i] /= kernelYSum;
  }

  //println(kernelYSum);
  //println(kernelXSum);

  // step 1: perform passes on every single row, without doing 
  // cross-row calculations. This is the "horizontal pass"

  println("Performing first pass");
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {

      // we MUST split the colors into their components
      // or else there is risk of being bound by the 8-bit color ceiling
      double red = 0;
      double green = 0;
      double blue = 0;

      // loop through the horizontal kernel, multiplying the color components
      // at this index, and its neighboring items
      // line the indices up such that center of kernel multiplies by this index
      int startKernelIndex = (kernelXLength / 2) - x;
      int endKernelIndex = (kernelXLength / 2) + img.width - x;
      assert(startKernelIndex >= 0);
      assert(endKernelIndex <= kernelXLength);
      assert(endKernelIndex >= (kernelXLength / 2));

      int rowX = 0;
      double weightSum = 0;
      for (int k = startKernelIndex; k < endKernelIndex; k++) {
        weightSum += kernelX[k];
        red += red(img.pixels[y * img.width + rowX]) * kernelX[k];
        green += green(img.pixels[y * img.width + rowX]) * kernelX[k];
        blue += blue(img.pixels[y * img.width + rowX]) * kernelX[k];
        rowX++;
      }

      // adjust for corners that dont get as much weight
      red *= (2 - weightSum); 
      green *= (2 - weightSum); 
      blue *= (2 - weightSum); 

      // then set the pixel in this row
      img.pixels[y * img.width + x] = color((float)red, (float)green, (float)blue);
    }
  }

  // step 2: vertical passes on every column

  println("Performing second pass");
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {

      // we MUST split the colors into their components
      // or else there is risk of being bound by the 8-bit color ceiling
      double red = 0;
      double green = 0;
      double blue = 0;

      // loop through the horizontal kernel, multiplying the color components
      // at this index, and its neighboring items
      // line the indices up such that center of kernel multiplies by this index
      int startKernelIndex = (kernelYLength / 2) - y;
      int endKernelIndex = (kernelYLength / 2) + img.height - y;
      assert(startKernelIndex >= 0);
      assert(endKernelIndex <= kernelYLength);
      assert(endKernelIndex >= (kernelYLength / 2));

      int rowY = 0;
      double weightSum = 0;
      for (int k = startKernelIndex; k < endKernelIndex; k++) {
        weightSum += kernelY[k];
        red += red(img.pixels[rowY * img.width + x]) * kernelY[k];
        green += green(img.pixels[rowY * img.width + x]) * kernelY[k];
        blue += blue(img.pixels[rowY * img.width + x]) * kernelY[k];
        rowY++;
      }

      red *= 2 - weightSum;
      green *= 2 - weightSum;
      blue *= 2 - weightSum;

      // then set the pixel in this row
      img.pixels[y * img.width + x] = color((float)red, (float)green, (float)blue);
    }
  }

  // having a function like this seems to go against the purpose of draw() lol 
  updatePixels();
}
