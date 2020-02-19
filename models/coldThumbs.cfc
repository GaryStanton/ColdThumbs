/**
* @author Gary Stanton
* ColdThumbs main component
* ColdThumbs is a ColdFusion component to dynamically resize and cache images.
*/
component singleton accessors="true"{
	/**
	 * Filesystem location of the folder in which to store cached images
	 */
	property type="string" name="cacheFolder" default="";

	/**
	 * The URL of the cached folder
	 * This will be included in returned URLs
	 */
	property type="string" name="cacheURL" default="cached";

	/**
	 * The maximum width an image may be output.
	 * Use this to avoid huge images that may hog server resources to generate
	 */
	property type="numeric" name="maxWidth" default="5000";

	/**
	 * The maximum height an image may be output.
	 * Use this to avoid huge images that may hog server resources to generate
	 */
	property type="numeric" name="maxHeight" default="5000";

	/**
	 * Default JPEG Quality
	 * Value between 0 & 1
	 */
	property type="numeric" name="jpegQuality" default="0.8";

	/**
	 * Interpolation to use when resizing images
	 */
	property type="string" name="interpolation" default="mitchell";

	/**
	 * Supported mime types
	 */
	property type="array" name="AllowedMimeTypes";

	/**
	* AllowedExtensions
	*/
	property type="array" name="AllowedExtensions";

	/**
	 * Keep filenames. When true, the cached name will retain the original filename with a truncated hash. Use when it is desirable for keywords to be included in returned images.
	 */
	property type="boolean" name="keepFilenames" default="true";

	/**
	* Spawn new threads to resize images
	*/
	property type="boolean" name="useThreading" default="true";

	/**
	 * Struct to hold information about resizing threads
	 */
	property type="struct" name="runningThreads";

	/**
	 * Array to hold calls queued for processing
	 */
	property type="struct" name="queuedThreads";

	/**
	 * Maximum number of threads to spawn. Remaining image processing requests will be held in a queue.
	 */
	property type="numeric" name="maxThreads" default=2;

	/**
	* Set the location of an ImageMagick binary to use this over native Java image resizing.
	*/
	property type="string" name="imageMagickLocation";

	/**
	* An instance of CFConcurrent.ExecutorService - https://github.com/pixl8/cfconcurrent
	* When available, ColdThumbs will use the CFConcurrent framework to handle threading over native CFThread
	*/
	property type="cfconcurrent.ExecutorService" name="ExecutorService" default="";

	/**
	* Constructor
	*/
	function init(){
		setRunningThreads({});
		setQueuedThreads({});
		setAllowedMimeTypes([
			'image/jpeg',
			'image/pjpeg',
			'image/png',
			'image/gif',
			'image/tiff',
			'image/bmp',
			'image/x-windows-bmp'
		]);
		setAllowedExtensions([
			'JPG',
			'JPEG',
			'GIF',
			'PNG',
			'BMP',
			'TIF',
			'TIFF'
		]);
		setCacheFolder(ExpandPath('./cached'));

		return this;
	}

	/**
	* getMemento
	*/
	function getMemento(){
		return Variables;
	}

	/**
	* Normalise the file path by replacing back slashes and removing duplicates
	* @path 	(Required) the path to normalise
	* @return 	String - normalised path.
	*/
	private function normalisePath(required string path){
		return replace(replace(Arguments.path, '\', '/', 'ALL'), '//', '/', 'ALL');
	}

	/**
	* Override default getCacheFolder to run through normalise function
	* @return 	Normalised cache folder location
	*/
	function getCacheFolder(){
		return normalisePath(variables.CacheFolder);
	}


	/**
	* Create the cache folder if it doesn't exist
	* @return 	Cache folder path
	*/
	string function checkCacheFolder(){
		if (!directoryExists(getCacheFolder())) {
			directoryCreate(getCacheFolder());
		}

		return getCacheFolder();
	}

	/**
	* Check to see if the current request is in a thread, as we can't have nested threads
	* Thanks to Mark Mandel: https://www.compoundtheory.com/how-to-tell-if-code-is-being-run-inside-a-cfthread-tag/
	*/
	private boolean function isRequestInThread(){
        var Thread = createObject("java","java.lang.Thread");
        if(Thread.currentThread().getThreadGroup().getName() eq "cfthread") {
            return true;
        }
        return false;
	}


	/**
	* Write an image to the cache folder
	* @imageObject 	(required) The image object to write to the cache
	* @filename 	(required) The filename to use when writing to the cache
	* @return 		Cached image path
	*/
	string function writeImageToCache(
			required imageObject
		, 	required string filename
		, 	numeric jpegQuality = getJpegQuality()
	){

		// Check cache folder exists
		checkCacheFolder();

		// Create function local copy of the image to work from 
		cfsilent(){writeDump(Arguments.imageObject)}; // Bug in Lucee will throw an error when duplicating a blank image without dumping first. LDEV-1906
		Local.theImage = duplicate(Arguments.imageObject);

		// Write to cache folder
		try {
			imageWrite(Local.theImage.getImageObject(), getCacheFolder() & '/' & Arguments.filename, Arguments.jpegQuality, true);
		}
		catch (any e) {
			return 'Error writing image to cache';
		}

		return Arguments.filename;
	}


	/**
	* Checks the cache folder to see if a given file exists
	* @filename 	(required) The image file name
	* @return 		Boolean
	*/
	boolean function checkCachedImageExists(required string filename){
		return fileExists(getCacheFolder() & '/' & Arguments.filename);
	}


	/**
	* Get a struct of file info from a remote URL
	* @url 						(required) The URL of the image
	* @authenticationString 	An authentication string if one is required (user:pass)
	* @return 					File info struct
	*/
	private struct function getRemoteFileInfo(required string url, string authenticationString = ''){
		if (len(Arguments.authenticationString)) {
			cfhttp(url="#Arguments.url#", result="Local.RemoteFileHead", method="HEAD") {
				cfhttpparam( type="header", name="Authorization", value="Basic #ToBase64(Arguments.authenticationString)#" );
			}
		}
		else {
			cfhttp(url="#Arguments.url#", result="Local.RemoteFileHead", method="HEAD");
		}

		if (ListFirst(Local.RemoteFileHead.statuscode, ' ') == 200) {
			Local.imageFileInfo = {
				src 			= Arguments.url,
				name 			= listLast(Arguments.url, '/'),
				extension		= listLast(Arguments.url, '.'),
				filename 		= ListDeleteAt(ListLast(Arguments.url, '/'), ListLen(ListLast(Arguments.url, '/'), '.'), '.'),
				lastModified 	= StructKeyExists(Local.RemoteFileHead.ResponseHeader, 'Last-modified') ? Local.RemoteFileHead.ResponseHeader['Last-modified'] : '',
				status 			= ListFirst(Local.RemoteFileHead.statuscode, ' '),
				mimeType 		= StructKeyExists(Local.RemoteFileHead, 'mimetype') ? Local.RemoteFileHead.mimetype : (structKeyExists(Local.RemoteFileHead.ResponseHeader, 'Content-Type') ? ListFirst(Local.RemoteFileHead.ResponseHeader['Content-Type'], ';') : '') 
			};
		}
		else {
			Local.imageFileInfo = {
				status 			= ListFirst(Local.RemoteFileHead.statuscode, ' ')
			};
		}
		return Local.imageFileInfo;
	}


	/**
	* Get a struct of file info from a local path
	* @path 					(required) The path of the image
	* @return 					File info struct
	*/
	private struct function getLocalFileInfo(required string path){
		if (fileExists(Arguments.path)) {
			Local.path = normalisePath(Arguments.path);
		}
		else if (fileExists(expandPath(Arguments.path))) {
			Local.path = normalisePath(expandPath(Arguments.path));
		}

		if (structKeyExists(Local, 'path')) {
			// Get file info (Java seems much quicker than `getFileInfo()`)
			Local.fileObj 		= createObject("java", "java.io.File").init(Local.path);
			Local.imageFileInfo = {
				src 			= Local.path,
				name 			= listLast(replace(Local.path, '\', '/', 'all'), '/'),
				extension 		= listLast(Arguments.path, '.'),
				filename 		= ListDeleteAt(ListLast(Arguments.path, '/'), ListLen(ListLast(Arguments.path, '/'), '.'), '.'),
				lastModified 	= createObject("java", "java.util.Date").init(Local.fileObj.lastModified()),
				mimeType 		= FilegetMimeType(Local.path),
				status 			= 200
			};

			Local.imageFileInfo.filename = ListDeleteAt(Local.imageFileInfo.name, ListLen(Local.imageFileInfo.name, '.'), '.');
		}
		else {
			Local.imageFileInfo = {
				status 			= 404
			};
		}

		return Local.imageFileInfo;
	}


	/**
	* Get a struct of file info
	* @src 						(required) The location (path or URL) of the image
	* @authenticationString 	An authentication string if one is required (user:pass)
	* @return 					File info struct
	*/
	function getImageFileInfo(required string src, string authenticationString = ''){
		if (left(src, 4) == 'http') {
			Local.fileInfo = getRemoteFileInfo(
				url 					= Arguments.src,
				authenticationString 	= Arguments.authenticationString
			);
		}
		else {
			Local.fileInfo = getLocalFileInfo(
				path 					= Arguments.src
			);
		}

		return Local.fileInfo;
	}


	/**
	* Generate a cached file name from image file info
	* @fileInfo 		Struct of image file information generated by the getLocalFileInfo or getRemoteFileInfo functions
	* @width 			Width of cached file
	* @height 			Height of cached file
	* @fixCanvas		Whether the fixCanvas flag was set 
	* @interpolation 	Interpolation to use for the resizing
	* @extension 		Override the file extension
	* @return 			Cached filename string
	*/
	string function generateCachedFilename(
		required struct  fileInfo, 
		required numeric width,
		required numeric height, 
				 boolean fixCanvas 	  	= false,
				 string  interpolation  = getInterpolation(),
				 string  extension 	  	= '' ){

		// Generate extension
		Arguments.extension = (Len(Arguments.extension) ? Arguments.extension : Arguments.fileInfo.extension);
		Arguments.extension = ArrayFindNoCase(getAllowedExtensions(), Arguments.extension) ? Arguments.extension : 'jpg';
		Local.hash = Hash(Arguments.fileInfo.filename & Arguments.width & Arguments.height & Arguments.interpolation & Arguments.fileInfo.lastModified & Arguments.fixCanvas & '.' & Arguments.fileInfo.extension);
		return (getKeepFilenames() ? Replace(REReplace(Arguments.fileInfo.filename, "[^0-9a-zA-Z -]", "", "ALL"), ' ', '-', 'ALL') & '_' & left(Local.hash, 6) : Local.hash) & '.' & Arguments.extension;
	}


	/**
	* Resize the image
	* @theImage 				The extended image object
	* @cachedFilename 			The filename to use when saving the cached image
	* @fileInfo 				A struct of file info
	* @authenticationString 	An authentication string if one is required (user:pass)
	* @width 					Width of cached file
	* @height 					Height of cached file
	* @fixCanvas 				When true, fix the canvas size to the specified dimensions, whilst proportionally resizing the content. e.g. You may want to create a uniform square image from a portrait or landscape image.
	* @interpolation 			Interpolation to use for the resizing
	* @backgroundColor			When using the fixCanvas method, the resulting image may contain a blank area that should be filled with a colour. (hex or r,g,b)
	*/
	private function resizeImage(
		required struct  theImage,
		required string  cachedFilename,
		required struct  fileInfo,
		required numeric width,
		required numeric height, 
				 boolean fixCanvas            = false,
				 string  interpolation        = getInterpolation(),
				 numeric jpegQuality 		  = getJpegQuality(),
				 string  backgroundColor,         
				 string  authenticationString = '' ){

		// Get image
		Arguments.theImage.readImage(
			src 					= Arguments.fileInfo.src,
			authenticationString 	= Arguments.authenticationString
		);

		// Resize image
		Arguments.theImage.resize(
			argumentCollection = Arguments
		);

		// Write to cache
		writeImageToCache(
			imageObject 		= Arguments.theImage,
			filename 			= Arguments.cachedFilename,
			jpegQuality 			= Arguments.jpegQuality
		);
	}


	/**
	* Spawn a new thread to resize an image
	* @theImage 				The extended image object
	* @cachedFilename 			The filename to use when saving the cached image
	* @fileInfo 				A struct of file info
	* @authenticationString 	An authentication string if one is required (user:pass)
	* @width 					Width of cached file
	* @height 					Height of cached file
	* @fixCanvas 				When true, fix the canvas size to the specified dimensions, whilst proportionally resizing the content. e.g. You may want to create a uniform square image from a portrait or landscape image.
	* @interpolation 			Interpolation to use for the resizing
	* @backgroundColor			When using the fixCanvas method, the resulting image may contain a blank area that should be filled with a colour. (hex or r,g,b)
	*/
	private function resizeImageInThread(
		required struct  theImage,
		required string  cachedFilename,
		required struct  fileInfo,
 				 string  authenticationString 	= '',
 				 numeric width 					= 0,
 				 numeric height 				= 0,
 				 boolean fixCanvas 				= false, 
 				 string  interpolation          = getInterpolation(),  
 				 numeric jpegQuality 			= getJpegQuality(),
 				 string  backgroundColor
		) {

		// Queue threads
		if (structCount(getRunningThreads()) >= getMaxThreads()) {

			if (!(structKeyExists(getRunningThreads(), Arguments.cachedFileName)) && !(structKeyExists(getQueuedThreads(), Arguments.cachedFilename))) {
				getQueuedThreads()[Arguments.cachedFileName] = duplicate(Arguments);
				Arguments.theImage.setStatus('Queued');
			}
		}
	
		// Resize
		else {
			Arguments.theImage.setStatus('Resizing');

			// Check to see if we already have a thread running for this image. We'll overwrite it if it's been running for longer than 300 seconds.
			if (!(StructKeyExists(getRunningThreads(), Arguments.cachedFilename) && StructKeyExists(getRunningThreads()[Arguments.cachedFilename], 'StartTime') && dateDiff('s', getRunningThreads()[Arguments.cachedFilename].StartTime, Now()) <= 300)) {

				// Placeholder in runningThreads struct - will be overwritten from inside the thread
				getRunningThreads()[Arguments.cachedFileName] = {
					StartTime = Now()
				};

				// Create a new thread in which to run resizing functions
				thread 
					name            	= Arguments.cachedFilename
					action          	= "run"
					fileInfo        	= Arguments.fileInfo
					threadArguments 	= Arguments
					theImage        	= Arguments.theImage
					cachedFilename  	= Arguments.cachedFileName
				{
					// Long timeout, as we can't spawn child threads for each new item in the queue - they'll all be running in the first spawned thread.
					cfsetting( requesttimeout="999999" );

					// Put the thread meta into the runningThreads struct
					getRunningThreads()[Attributes.cachedFileName] = duplicate(thread);

					try {
						resizeImage(
							argumentCollection 		= Attributes.threadArguments,
							theImage 				= Attributes.theImage,
							cachedFilename 			= Attributes.cachedFilename,
							fileInfo 				= Attributes.fileInfo
						);
					}
					catch (any e) {
					//	systemOutput( Now(), true );
					//	systemOutput( e, true );
						Attributes.theImage.setStatus('Error');
						Attributes.theImage.setStatusDetail(e.Message);
						structDelete(getRunningThreads(), Thread.name);
					}

					structDelete(getRunningThreads(), Thread.name);

					// Now we've cleared a thread, we can process the thread queue
					processQueue();
				}
			}
		}
	}


	/**
	* Process images stored in the thread queue
	*/
	private function processQueue(){
		// Loop through queue
		for (Local.thisImage in getQueuedThreads()) {
			// Check we have some threads to use
			if (structCount(getRunningThreads()) < getMaxThreads()) {
				try {
					// Duplciate struct and delete from queue
					Local.thumbStruct = duplicate(getQueuedThreads()[Local.thisImage]);
					structDelete(getQueuedThreads(), Local.thisImage);
					// Push to getThumbnail function
					getThumbnail(argumentCollection = Local.thumbStruct);
				}
				catch (any e) {
					processQueue();
				}
			}
		}
	}


	/**
	* Retrieve a thumbnail from the cache or generate a new one from source
	* @src 						(required) The location (path or URL) of the image
	* @authenticationString 	An authentication string if one is required (user:pass)
	* @width 					Width of cached file
	* @height 					Height of cached file
	* @imageType 				Convert the resized image to a different type: (JPG|GIF|PNG|BMP) - Matches the source image type by default.
	* @fixCanvas 				When true, fix the canvas size to the specified dimensions, whilst proportionally resizing the content. e.g. You may want to create a uniform square image from a portrait or landscape image.
	* @interpolation 			Interpolation to use for the resizing
	* @backgroundColor			When using the fixCanvas method, the resulting image may contain a blank area that should be filled with a colour. (hex or r,g,b)
	* @regenerate				When true, force the regeneration of the thumbnail overwriting an existing image in the cache
	* @useThreading 			When true, the image will spawn a new thread in which the resize process will occur.
	*/
	function getThumbnail(
		required 	string 	src, 
					string 	authenticationString = '',
				 	numeric width 			= 0,
				 	numeric height 			= 0,
					string 	imageType 		= '',
					boolean fixCanvas 		= false,
					string  interpolation   = getInterpolation(),     
					numeric jpegQuality 	= getJpegQuality(),
					string 	backgroundColor,
					boolean regenerate 		= false,
					boolean useThreading 	= getUseThreading()
	){
		Local.Tick = getTickCount();

		// Create extended image instance
		Local.theImage = new extendedImage();

		// Check for imageMagick
		if (len(getImageMagickLocation()) && fileExists(getImageMagickLocation())) {
			Local.theImage.setImageMagickLocation(getImageMagickLocation());
		}

		// Get file info
		Local.fileInfo = getImageFileInfo(
			src 					= Arguments.src,
			authenticationString 	= Arguments.authenticationString
		);

		// Check we got the file ok
		if (Local.fileInfo.status != 200) {
			Local.theImage.setStatus('Error');
			Local.theImage.setStatusDetail('Error retrieving file at: ' & Arguments.src);
		}
		else if (!ArrayFindNoCase(getAllowedMimeTypes(), Local.fileInfo.MimeType)) {
			Local.theImage.setStatus('Error');
			Local.theImage.setStatusDetail('Unsupported file type at: ' & Arguments.src);
		}
		else {
			// Get cached filename
			Local.cachedFilename = generateCachedFilename(
				fileInfo 				= Local.fileInfo,
				width 					= Arguments.width,
				height 					= Arguments.height,
				fixCanvas 				= Arguments.fixCanvas,
				extension 				= structKeyExists(Arguments, 'imageType') && ListFindNoCase('jpg,jpeg,gif,png,bmp,tif,tiff', Arguments.imageType) ? Arguments.imageType : ''
			);

			// Check cache
			if (Arguments.regenerate || (!checkCachedImageExists(Local.cachedFilename))) {

				Local.theImage.cached = false;

				// Check to see if we have an instance of the CFConcurrent executor service
				if (Arguments.useThreading && (!isNull(getExecutorService())) && IsInstanceOf(getExecutorService(), 'cfconcurrent.ExecutorService')) {
					// Call task
					var task 	= new generateThumbnailTask(
						argumentCollection 	= Arguments,
						theImage			= Local.theImage,
						cachedFilename		= Local.cachedFilename,
						fileInfo			= Local.fileInfo,
						coldThumbs  		= this
					);
					getExecutorService().submit( task );
				}

				// Native threading
				else if (Arguments.useThreading && (!isRequestInThread())) {
					resizeImageInThread(
						argumentCollection 		= Arguments,
						theImage 				= Local.theImage,
						cachedFilename 			= Local.cachedFilename,
						fileInfo 				= Local.fileInfo
					);
				}

				// No threading
				else {
					// Put some meta into the runningThreads struct
					getRunningThreads()[Local.cachedFileName] = {Name = Local.cachedFilename, StartTime = Now()};

					resizeImage(
						argumentCollection 		= Arguments,
						theImage 				= Local.theImage,
						cachedFilename 			= Local.cachedFilename,
						fileInfo 				= Local.fileInfo
					);
					structDelete(getRunningThreads(), Local.cachedFilename);
					if (isRequestInThread()) {
						processQueue();
					}
				}
			}
			else {
				Local.theImage.cached = true;
				Local.theImage.setStatus('Success');
			}

			// Write data to image object
			Local.theImage.setSrc(Arguments.src);
			Local.theImage.setfileName(Local.cachedFilename);
			Local.theImage.setPath(normalisePath(getCacheFolder() & '/' & Local.cachedFilename));
			Local.theImage.setURL(normalisePath(getCacheURL() & '/' & Local.cachedFilename));
			Local.theImage.setMimeTypeFromExtension(listLast(Local.cachedFilename, '.'));
			Local.theImage.setTimer(getTickCount() - Local.tick);
		}

		return Local.theImage;
	}
}
