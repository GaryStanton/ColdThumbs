# ColdThumbs v2

---

ColdThumbs is a CFML component to dynamically resize and cache images.

## Author

Developed by Gary Stanton
- http://www.garystanton.co.uk
- http://www.simianenterprises.co.uk

## What is ColdThumbs?
Many CFML applications and websites require the ability to display images at multiple sizes, even moreso now we have to think about screens of different pixel densities.
When passed a local or remote source image and a desired image size, ColdThumbs will first check for a cached instance of the image and if none is found, automatically resize the source image and save it out for future use.
The filename of the resized image is made using a hash of its dimensions and other meta - so if the source image is changed, the cached versions are automatically regenerated when required.
Optionally, ColdThumbs will spawn new threads to resize images, maintaining an internal queue so as to work within the memory limitations of your server environment.
ColdThumbs can return the location of the resized image in the filesystem, a URL string, or write the image itself to the browser.


## Requirements
ColdThumbs requires ColdFusion 11+ or Lucee 5+


## Installation
The recommended method of installation is via CommandBox. Simply navigate to your project and run:
`install coldthumbs`
The full CommandBox installation includes a suite of TestBox tests, DocBox documentation and some examples.
You may also manually download ColdThumbs from GitHub. The only files requried are in the model folder.

### ImageMagick
ColdThumbs is able to use the internal CFML resizing functionality, but for best results I recommend making use of [https://www.imagemagick.org/](ImageMagick).
Simply update the `ImageMagickLocation` property of the ColdThumbs CFC with the location of your `Magick.exe`

## Usage
ColdThumbs may be used as a ColdBox module, or standalone in any CFML application. 

### Instantiation
The `coldThumbs.cfc` component is designed to be instantiated as a singleton.
`coldThumbs = new coldThumbs.model.coldThumbs();`

When processing an image, ColdThumbs will create and return instances of the `extendedImage` object.

### Resizing
The main function of ColdThumbs is `getThumbnail()`. You may pass parameters to this function to indiciate the source of the image you'd like to process as well as desired dimensions.
ColdThumbs will resize the image and store a copy of it in a local cache folder. Cached filenames are hashed with image properties, ensuring that if the source file changes a new version will be cached automatically.
The resulting instance of `extendedImage` contains the location of the cached image.

### Demo
Get up and running with a local demo, by running `box install` in the ColdThumbs folder. The demo includes some example code, a test suite and API documentation.
You can also find a live demo hosted at: http://www.simianenterprises.co.uk/ColdThumbs


