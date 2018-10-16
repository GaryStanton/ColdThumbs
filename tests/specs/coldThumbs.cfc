component extends="tests.BaseTest" appMapping="/tests" {
	/**
	* Run tests
	*/
	function beforeAll(){
		super.beforeAll();
		variables.coldThumbs      = getInstance( 'models.coldThumbs' );
		coldThumbs.setCacheFolder(expandPath('.') & '/resources/cached/');
		coldThumbs.setkeepFilenames(false);
		// Delete existing cached files
		for (Local.thisFile in directoryList(coldThumbs.getCacheFolder())) {
			fileDelete(Local.thisFile);
		};
	}

	function run(){
		describe( "Component tests", function(){
		
			it( "Can return a memento", function(){
				expect(	coldThumbs.getMemento() ).toBeTypeOf( 'struct' );
			});

		});


		describe( "Image tests", function(){
			it( "Can find the cache folder", function() {
				coldThumbs.checkCacheFolder();
				expect(directoryExists(coldThumbs.getCacheFolder())).toBeTrue();
			});

			it( "Can write an image to the cache folder", function() {
				var theImage = getInstance( 'models.extendedImage' ).readImage(expandPath('.') & '/resources/testImage.jpg');
				var filename = 'testCacheImage.jpg';
				coldThumbs.writeImageToCache(
					imageObject = theImage,
					filename 	= filename
				);

				expect(fileExists(coldThumbs.getCacheFolder() & filename)).toBeTrue();
				expect(coldThumbs.checkCachedImageExists(filename = filename)).toBeTrue();
			});

			it( "Can get file info from a remote file", function(){
				expect(coldThumbs.getImageFileInfo(src = 'https://placebear.com/600/600.jpg').Status).toBe(200);
				expect(coldThumbs.getImageFileInfo(src = 'https://pleasefail.jpg').Status).notToBe(200);
			});

			it( "Can get file info from a local file", function(){
				expect(coldThumbs.getImageFileInfo(src = expandPath('.') & '/resources/testImage.jpg').Status).toBe(200);
				expect(coldThumbs.getImageFileInfo('resources/testImage.jpg').Status).toBe(200);
			});

			it( "Can generate a cached filename", function(){
				var fileInfo = coldThumbs.getImageFileInfo(src = expandPath('.') & '/resources/testImage.jpg');
				expect(coldThumbs.generateCachedFilename(fileInfo, 600, 600)).toBe(Hash(fileInfo.filename & 600 & 600 & coldThumbs.getInterpolation() & fileInfo.lastModified & false & '.' & fileInfo.extension) & '.' & fileInfo.extension);
			});
		});

		describe( "Generate thumbnails from scratch", function(){

			it( "Can output a thumbnail from a local image", function(){
				var fileInfo = coldThumbs.getImageFileInfo(src = expandPath('.') & '/resources/testImage.jpg');

				expect(coldThumbs.getThumbnail(
					src						= 'resources/testImage.jpg',
					outputType				= 'url',
					width					= 400,
					height 					= 400
				).getURL()).toBe('cached/' & coldThumbs.generateCachedFilename(fileInfo, 400, 400));
			});

			it( "Can output a thumbnail from a URL", function(){
				var fileInfo = coldThumbs.getImageFileInfo(src = 'https://placebear.com/600/600.jpg');
				expect(coldThumbs.getThumbnail(
					src						= 'https://placebear.com/600/600.jpg',
					outputType				= 'url',
					width					= 400,
					height 					= 400
				).getURL()).toBe('cached/' & coldThumbs.generateCachedFilename(fileInfo, 400, 400));
			});

			it( "Can output a thumbnail with threading", function(){
				var fileInfo = coldThumbs.getImageFileInfo(src = expandPath('.') & '/resources/testImage.jpg');

				expect(coldThumbs.getThumbnail(
					src						= 'resources/testImage.jpg',
					outputType				= 'url',
					width					= 400,
					height 					= 400,
					useThreading 			= true
				).getURL()).toBe('cached/' & coldThumbs.generateCachedFilename(fileInfo, 400, 400));
			});		
		});

		describe( "Return thumbnails from cache", function(){
			it( "Can output a thumbnail from a local image", function(){
				var fileInfo = coldThumbs.getImageFileInfo(src = expandPath('.') & '/resources/testImage.jpg');

				expect(coldThumbs.getThumbnail(
					src						= 'resources/testImage.jpg',
					outputType				= 'url',
					width					= 400,
					height 					= 400
				).getURL()).toBe('cached/' & coldThumbs.generateCachedFilename(fileInfo, 400, 400));
			});

			it( "Can output a thumbnail from a URL", function(){
				var fileInfo = coldThumbs.getImageFileInfo(src = 'https://placebear.com/600/600.jpg');
				expect(coldThumbs.getThumbnail(
					src						= 'https://placebear.com/600/600.jpg',
					outputType				= 'url',
					width					= 400,
					height 					= 400
				).getURL()).toBe('cached/' & coldThumbs.generateCachedFilename(fileInfo, 400, 400));
			});

			it( "Can output a thumbnail with threading", function(){
				var fileInfo = coldThumbs.getImageFileInfo(src = expandPath('.') & '/resources/testImage.jpg');

				expect(coldThumbs.getThumbnail(
					src						= 'resources/testImage.jpg',
					outputType				= 'url',
					width					= 400,
					height 					= 400,
					useThreading 			= true
				).getURL()).toBe('cached/' & coldThumbs.generateCachedFilename(fileInfo, 400, 400));
			});		
		});
	}
}