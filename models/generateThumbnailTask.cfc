/**
* @author Gary Stanton
* ColdThumbs image resize task for use with CFConcurrent
* ColdThumbs is a ColdFusion component to dynamically resize and cache images.
*/
component {

	/**
	* @coldThumbs 				The instance of ColdThumbs
	* @theImage 				The extended image object
	* @cachedFilename 			The filename to use when saving the cached image
	* @fileInfo 				A struct of file info
	* @authenticationString 	An authentication string if one is required (user:pass)
	* @width 					Width of cached file
	* @height 					Height of cached file
	* @fixCanvas 				When true, fix the canvas size to the specified dimensions, whilst proportionally resizing the content. e.g. You may want to create a uniform square image from a portrait or landscape image.
	* @backgroundColor			When using the fixCanvas method, the resulting image may contain a blank area that should be filled with a colour. (hex or r,g,b)
	*/
	function init(
		required 		 coldThumbs,
		required struct  theImage,
		required string  cachedFilename,
		required struct  fileInfo,
 				 string  authenticationString 	= '',
 				 numeric width 					= 0,
 				 numeric height 				= 0,
 				 boolean fixCanvas 				= false, 
 				 string  interpolation          = "mitchell",                                                                                    
 				 string  backgroundColor 		= '000000'
		){

		Variables.instance.coldThumbs           = Arguments.coldThumbs;
		Variables.instance.theImage             = Arguments.theImage;
		Variables.instance.cachedFilename       = Arguments.cachedFilename;
		Variables.instance.fileInfo             = Arguments.fileInfo;
		Variables.instance.authenticationString = Arguments.authenticationString;
		Variables.instance.width                = Arguments.width;
		Variables.instance.height               = Arguments.height;
		Variables.instance.fixCanvas            = Arguments.fixCanvas;
		Variables.instance.interpolation        = Arguments.interpolation;
		Variables.instance.backgroundColor      = Arguments.backgroundColor;
		Variables.instance.result = { 
			name      = Arguments.cachedFilename,
			startTime = Now(),
			error     = {}
		};
		return this;
	}



	/**
	* Resize image
	*/
	function call() {
		result.callStartTick = getTickCount();

		// Put some meta into the runningThreads struct
		var threads = Variables.instance.ColdThumbs.getRunningThreads();
		threads[Variables.instance.cachedFileName] = result;
		Variables.instance.ColdThumbs.setRunningThreads(threads);

		try {
			// Get image
			Variables.instance.theImage.readImage(
				src 					= Variables.instance.fileInfo.src,
				authenticationString 	= Variables.instance.authenticationString
			);

			// Resize image
			Variables.instance.theImage.resize(
				argumentCollection 		= Variables.instance
			);

			// Write to cache
			Variables.instance.coldThumbs.writeImageToCache(
				imageObject 			= Variables.instance.theImage,
				filename 				= Variables.instance.cachedFilename
			);
		}
		catch (any e) {
			result.error = e;
			writeLog("ColdThumbs could not resize an image: #Variables.instance.fileInfo.src#. Result: #serializeJSON(result)#");
		}

		structDelete(Variables.instance.ColdThumbs.getRunningThreads(), Variables.instance.cachedFilename);

		result.endTick = getTickCount();
		return result;
	}
}