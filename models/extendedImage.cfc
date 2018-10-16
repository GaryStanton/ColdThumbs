/**
* @author Gary Stanton
* Extended image component
* A wrapper for a ColdFusion image object with some extended functionality
*/
component accessors="true"{
	/**
	 * The image struct
	 */
	property name="imageObject";

	/**
	 * The source of the image object
	 */
	property name="src" type="string";

	/**
	 * The URL of the image object
	 */
	property name="URL" type="string";

	/**
	 * The mime type of the image object
	 */
	property name="mimeType" type="string";

	/**
	 * The path of the image object
	 */
	property name="path" type="string";

	/**
	 * The filename of the image object
	 */
	property name="filename" type="string";

	/**
	 * The width of the image object
	 */
	property name="width" type="string";

	/**
	 * The height of the image object
	 */
	property name="height" type="string";

	/**
	 * The status of the image object
	 */
	property name="status" type="string";

	/**
	 * More detail about the status of the image object
	 */
	property name="statusDetail" type="string";

	/**
	 * A timer
	 */
	property name="timer" type="numeric";

	/**
	* Set the location of an ImageMagick binary to use this over native Java image resizing.
	*/
	property name="imageMagickLocation";


	/**
	* Constructor
	*/
	function init(){
		return this;
	}

	/**
	* getMemento
	*/
	function getMemento(){
		return Variables;
	}

	/**
	 * Check that the image object contains an image
	 * @return boolean
	 */
	 function containsImage() {
		if (isImage(getImageObject())) {
			return true;
		}
		return false;
	 }

	/**
	* Given source dimensions and a new width or height, proportionally calculate the missing side
	* @srcWidth 		(required) Source width
	* @srcHeight 		(required) Source height
	* @newWidth			New width
	* @newHeight 		New height
	*/
	struct function getProportionalSizes(
		required numeric srcWidth,
		required numeric srcHeight,
		numeric newWidth 	= 0,
		numeric newHeight 	= 0
	){
		// Get ratio
		var ratio = min(Arguments.newWidth == 0 ? 100000 : Arguments.newWidth / Arguments.srcWidth, Arguments.newHeight == 0 ? 100000 : Arguments.newHeight / Arguments.srcHeight);
		return {
			width 	= int(Arguments.srcWidth*ratio),
			height 	= int(Arguments.srcHeight*ratio),
			ratio 	= ratio
		};
	}


	/**
	* Read an image from a URL
	* @url 						The url of the image
	* @authenticationString 	An authentication string if one is required (user:pass)
	* @return 					this
	*/
	private function getImageFromURL(required string url, string authenticationString = ''){
		try {
			if (len(Arguments.authenticationString)) {
				cfhttp(url="#Arguments.url#", result="Local.RemoteFile", method="GET") {
					cfhttpparam( type="header", name="Authorization", value="Basic #ToBase64(Arguments.authenticationString)#" );
				}
			}
			else {
				cfhttp(url="#Arguments.url#", result="Local.RemoteFile", method="GET");
			}
			setImageObject(imageRead(Local.RemoteFile.FileContent));
			setStatus('Success');
		}

		catch (any e) {
			createTextImage(
					textString = 'Unable to read image (URL)'
			);
			setStatus('Error');
			setStatusDetail(e.Message);
		}

		return this;
	}


	/**
	* Read an image from the filesystem
	* @src 		The location of the image
	* @return 	this
	*/
	private function getImageFromFileSystem(required string src){
		try {
			lock timeout="30" name="#Arguments.src#" type="readonly" { 
				setImageObject(imageRead(Arguments.src));
			}
			setStatus('Success');
		}

		catch (any e) {
			createTextImage(
					textString = 'Unable to read image (File)'
			);
			setStatus('Error');
			setStatusDetail(e.Message);
		}

		return this;
	}


	/**
	 * Read an image from the filesystem or from a URL
	 * @src 					(required) The location of the image. May be a filesystem path or a URL
	 * @authenticationString 	An authentication string if one is required (user:pass)
	 * @return 					this
	 */
	public function readImage(required string src, string authenticationString = '') {

		Local.tick = getTickCount();
		
		// Check to see if we're pulling from a URL
		if (Left(Arguments.src, 4) == 'http') {
			getImageFromURL(
				url 					= Arguments.src,
				authenticationString 	= Arguments.authenticationString
			);
		}
		else {
			getImageFromFileSystem(
				src 					= Arguments.src
			);
		}

		setSrc(Arguments.src);
		setTimer(getTickCount() - Local.tick);

		return this;
	}


	/**
	 * Create an image containing some text and populate the object with it
	 * @textString 			(required) The text to display in the image
	 * @width  				The width of the new image
	 * @height  			The height of the new image
	 * @canvasColor			The background colour (hex or r,g,b)
	 * @textColor 			The colour of the text (hex or r,g,b)
	 * @attributeCollection A struct to be passed to ImageDrawText (https://cfdocs.org/imagedrawtext)
	 * @return image object
	 */
	function createTextImage(
		required string textString, 
		numeric width              = 600, 
		numeric height             = 600,
		string canvasColor         = '000000',
		string textColor           = 'FFFFFF',
		struct attributeCollection = StructNew()
	) {

		// Default attributes
		Arguments.attributeCollection.font  = Arguments.attributeCollection.font  ?: 'Arial';
		Arguments.attributeCollection.size  = Arguments.attributeCollection.size  ?: '36';
		Arguments.attributeCollection.style = Arguments.attributeCollection.style ?: 'plain';

		Local.ThisImage = imageNew('', Arguments.width,  Arguments.height, 'rgb', Arguments.canvasColor);
		
		// Work out style integer
		Local.fontStyle = 0;
		if (Arguments.attributeCollection.style CONTAINS 'bold' AND Arguments.attributeCollection.style CONTAINS 'italic') 
			Local.fontStyle = 3;
		else if (Arguments.attributeCollection.style == 'bold') 
			Local.fontStyle = 1;
		else if (Arguments.attributeCollection.style == 'italic') 
			Local.fontStyle = 2;


		// Centre text
		Local.graphics 	= imageGetBufferedImage(Local.ThisImage).getGraphics();
		Local.font 		= createObject("java", "java.awt.Font").init(
			JavaCast( "string", Arguments.attributeCollection.font ), 
			JavaCast( "int", Local.fontStyle ), 
			JavaCast( "string", Arguments.attributeCollection.size )
		);

		Local.bounds 	= Local.graphics.getFontMetrics(Local.font).getStringBounds(Arguments.textString, Local.graphics);

		// Draw text
		imageSetAntialiasing(Local.ThisImage, 'on');
		imageSetDrawingColor(Local.ThisImage, Arguments.textColor);
		ImageDrawText(Local.ThisImage, Arguments.textString, (Arguments.width - Local.bounds.getWidth()) / 2, (Arguments.height - Local.bounds.getHeight()) / 2, Arguments.attributeCollection);
		setImageObject(Local.ThisImage);

		return this;
	}


	/**
	* Resize the image
	* @width 			Desired image width
	* @height 			Desired image height
	* @interpolation 	Interpolation to use for the resizing
	* @fixCanvas 		When true, fix the canvas size to the specified dimensions, whilst proportionally resizing the content. e.g. You may want to create a uniform square image from a portrait or landscape image.
	* @backgroundColor	When using the fixCanvas method, the resulting image may contain a blank area that should be filled with a colour. (hex or r,g,b)
	*/
	function resize(
		required 	numeric width 			= 0,
		required 	numeric height 			= 0,
					string interpolation 	= "mitchell",
					boolean fixCanvas 		= false,
					string backgroundColor  = "FFFFFF"
	){
		Local.tick = getTickCount();

		// Check we have an image to work with
		if (!containsImage()) {
			setStatus('Error');
			setStatusDetail('No image found');
			return this;
		}

		// Don't resize if image already has the correct dimensions
		if (Arguments.width == getImageObject().width && Arguments.height == getImageObject().height ) {
			setStatus('Success');
			setStatusDetail('No resizing required');
			return this;
		}

		// ImageMagick resize
		if (len(getImageMagickLocation()) && fileExists(getImageMagickLocation())) {
			// Create temporary filename
			Local.tempFilename = GetTempDirectory() & createUUID() & '.' & listLast(getSrc(), '.');
			// Resize the image in ImageMagick
			cfexecute( name='"#getImageMagickLocation()#"', arguments="""#getSrc()#"" -resize #Arguments.width GT 0 ? Arguments.width : ''##Arguments.height GT 0 ? 'x' & Arguments.height : ''# ""#Local.tempFilename#""", variable="Results", errorVariable="Error", timeout="120");
			// Read the temporary image into the object
			readImage(src = Local.tempFilename);
			// Delete temporary image
			try {
				fileDelete(Local.tempFilename);
			}
			catch (any e) {

			}
		}

		else {
			// Create function local copy of the image to work from
			cfsilent(){writeDump(getImageObject())}; // Bug in Lucee will throw an error when duplicating a blank image without dumping first. This uses a large amount of memory! - LDEV-1906
			Local.theImage = duplicate(getImageObject());

			// If we need a fixed canvas, create a new image to work with
			if (Arguments.fixCanvas) {
				// Get proportional sizing (Essentially if we're using a fixed canvas, we probably don't _want_ a proportional resize, but it's preferable to throwing an error if a dimension is not specified.)
				Local.propSize = getProportionalSizes(
					srcWidth 	= Local.theImage.width,
					srcHeight 	= Local.theImage.height,
					newWidth 	= Arguments.width,
					newHeight 	= Arguments.height
				);

				Local.fixedCanvasImage = ImageNew('', Arguments.width > 0 ? Arguments.width : Local.propSize.width, Arguments.height > 0 ? Arguments.height : Local.propSize.height, 'rgb', arguments.backgroundColor);
				// Force a proportional resize by blanking out the smallest side
				if(Local.theImage.width <= Local.theImage.height) {
					Arguments.width = 0;
				}
				else {
					Arguments.height = 0;	
				}
			}

			// We need to add 0.1 to the sizes to work around an occasional inaccuracy when resizing
			imageResize(Local.theImage, Arguments.width > 0 ? Arguments.width + 0.1 : '', Arguments.height > 0 ? Arguments.height + 0.1 : '', Arguments.interpolation);

			// If we have a fixed canvas, we need to paste the resized image onto the canvas we created earlier
			if (Arguments.fixCanvas) {
				imagePaste(Local.fixedCanvasImage, Local.theImage, (Local.fixedCanvasImage.width / 2) - (Local.theImage.width / 2), (Local.fixedCanvasImage.height / 2) - (Local.theImage.height / 2));
				Local.theImage = Local.fixedCanvasImage;
			}

			setImageObject(Local.theImage);
		}

		setTimer(getTickCount() - Local.tick);

		return this;
	}

	/**
	* setMimeTypeFromExtension
	* @extension 	(required) the extension of the image file
	*/
	function setMimeTypeFromExtension(required string extension){
		switch (arguments.extension) {
			case "jpg": case "jpeg":
				setMimeType('image/jpeg');
			break;
			case "gif":
				setMimeType('image/gif');
			break;
			case "png":
				setMimeType('image/x-png');
			break;
			case "bmp":
				setMimeType('image/bmp');
			break;
			case "tif,tiff":
				setMimeType('image/tiff');
			break;
		}

		return this;
	}


	/**
		* Output the image to the browser. This avoids the need to write the file to the disk or make use of the temporary folder used by `writeToBrowser()`
	*/
	public function outputImage(){

		if (Len(getPath()) && fileExists(getPath())) {
			if (!Len(getMimeType())) {
				setMimeTypeFromExtension(listLast(getPath(), '.'));
			}
			
			Local.fileObj 	= createObject("java", "java.io.File").init(getPath());
			cfheader( name = "Content-Length", value="#Local.fileObj.length()#" );
			cfcontent( file = getPath(), type = getMimeType() );
		}
		else if (containsImage()) {
			setMimeTypeFromExtension(listLast(getImageObject().source, '.'));
			cfcontent( variable = toBinary( getImageObject() ), type = getMimeType() );
		}

	}


	/**
	* Return image properties
	*/
	public function getImageProperties(){
		return {
				SRC 			= getSRC()
			,	URL 			= getURL()
			,	mimeType 		= getMimeType()
			,	path 			= getPath()
			,	filename 		= getFileName()
			,	status 			= getStatus()
			,	statusDetail 	= getStatusDetail()
			,	timer 			= getTimer()
		};
	}
}