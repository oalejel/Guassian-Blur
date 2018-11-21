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
  img = loadImage("myimage.png");


  ///// ---- will be placed in draw() later -------

  performBlur(img, 1.0);
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
  
  // compute the kernel, with a width and height equal to that of the image
  // 
  
  double kernelX[] = new double[img.width];
  double kernelY[] = new double[img.height];
  
  // fill the kernel by scaling our indices to go from -sigma to +sigma
  
  // might need a sum we are working with discrete values 
  // that will overestimate area under normal distr
  double kernelXSum = 0;  
  for (int i = 0; i < img.width; i++) {
    // fraction of stdev = (i - halfwidth) / halfwidth = (i / halfwidth) - 1
    double sigmaFraction = ((double)i / (img.width * 0.5)) - 1;
    double x = 3 * stdev * sigmaFraction;
    kernelX[i] = G(x, stdev);  
    kernelXSum += kernelX[i];
    println(kernelX[i]);
  }
  
  double kernelYSum = 0;  
  for (int i = 0; i < img.height; i++) {
    // fraction of stdev = (i - halfwidth) / halfwidth = (i / halfwidth) - 1
    double sigmaFraction = ((double)i / (img.height * 0.5)) - 1;
    double y = 3 * stdev * sigmaFraction;
    kernelY[i] = G(y, stdev);  
    kernelYSum += kernelY[i];
    println(kernelY[i]);
  }
  
  //println(kernelYSum);
  //println(kernelXSum);
  
  // perform passes on every single row, without doing cross-row calculations
  // this is the "horizontal pass"







  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      color c = img.pixels[y * img.width + x];
      
      
      
      // sort of inverts the color
      float rb = blue(c);
      float bg = green(c);
      float gr = red(c);
      color outColor = color(rb, gr, bg);
      
      
      
      pixels[y * width + x] = outColor;
    }
  }

  // having a function like this seems to go against the purpose of draw() lol 
  updatePixels();
}
