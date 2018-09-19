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

---

## Requirements
ColdThumbs requires ColdFusion 11+ or Lucee 5+

---

## Installation
The recommended method of installation is via CommandBox. Simply navigate to your project and run:
```bash
install coldthumbs
```
The full CommandBox installation includes a suite of TestBox tests, DocBox documentation and some examples.
You may also manually download ColdThumbs from GitHub. The only files requried are in the model folder.

---

## Usage
ColdThumbs may be used as a ColdBox module, or standalone in any CFML application. 

### Instantiation
The `coldThumbs.cfc` component is designed to be instantiated as a singleton.  
```cfc
var ColdThumbs  = new coldThumbs.models.coldThumbs();
```
or with ColdBox:
```cfc
var ColdThumbs  = getInstance("ColdThumbs@ColdThumbs");
```


When processing an image, ColdThumbs will create and return instances of the `extendedImage` object.

### Resizing
The main function of ColdThumbs is `getThumbnail()`. You may pass parameters to this function to indiciate the source of the image you'd like to process as well as desired dimensions.  
ColdThumbs will resize the image and store a copy of it in a local cache folder. Cached filenames are hashed with image properties, ensuring that if the source file changes a new version will be cached automatically.  

```cfc
cachedImage = ColdThumbs.getThumbnail(
    	src                  = 'your-large-image.jpg' // (required) The location (path or URL) of the image
    ,	authenticationString = 'user:pass'            // An authentication string if one is required (user:pass)
    ,	width                = 400                    // Width of cached file
    ,   height               = 0                      // Height of cached file
    ,   imageType            = 'png'                  // Convert the resized image to a different type: (JPG|GIF|PNG|BMP) - Matches the source image type by default.
    ,   fixCanvas            = false                  // When true, fix the canvas size to the specified dimensions, whilst proportionally resizing the content. e.g. You may want to create a uniform square image from a portrait or landscape image.
    ,   interpolation        = 'mitchell'             // Interpolation to use for the resizing
    ,   backgroundColor      = 'FFFFFF'               // When using the fixCanvas method, the resulting image may contain a blank area that should be filled with a colour. (hex or r,g,b)
    ,   regenerate           = false                  // When true, force the regeneration of the thumbnail overwriting an existing image in the cache
    ,   useThreading         = true                   // When true, the image will spawn a new thread in which the resize process will occur. 
);
```

The resulting instance of `extendedImage` contains the location of the cached image:

| Function |  |
| --- | --- |
| `getSrc()` | The full path of the source image |
| `getURL()` | The relative URL of the cached image |
| `getPath()` | The full local path of the cached image |
| `getFilename()` | The filename of the cached image |
| `getMimeType()` | The mime type of the cached image |
| `outputImage()` | Output the image to the browser |

See the [full API documentation](http://www.simianenterprises.co.uk/ColdThumbs/docs/) for detail of all functions.

### Threading
ColdThumbs is able to spawn new threads to resize images, returning the URL of the cached image before it is actually resized, so that you may avoid blocking of browser rendering. 
Out of the box ColdThumbs will use the internal threading functionality provided by `CFThread` and will queue threads to avoid overloading your server. You may set the maximum number of resizing threads by updating the `maxThreads` property, e.g. `coldThumbs.setMaxThreads(3);`.

#### CFConcurrent
If present in your application you may also make use of [CFConcurrent](https://github.com/pixl8/cfconcurrent) by simply providing an instance of the CFConcurrent executor service to ColdThumbs, e.g. `coldThumbs.setExecutorService(executorService);`


### ImageMagick
ColdThumbs will happily make use of the internal CFML resizing functionality, however this can result in a heavy load on your JVM and is the one area I have found ACF to drastically out perform Lucee.  
For best results I recommend making use of [ImageMagick](https://www.imagemagick.org/).  

Simply update the `ImageMagickLocation` property of the ColdThumbs CFC with the location of your `Magick.exe` binary:
```cfc
ColdThumbs.setImageMagickLocation("C:\Program Files\ImageMagick-7.0.8-Q16\magick.exe");
```
  

---

## Demo
Get up and running with a local demo, by running `box install` in the ColdThumbs folder. The demo includes some example code, a test suite and API documentation.  
You can also find a live demo hosted at: http://www.simianenterprises.co.uk/ColdThumbs
