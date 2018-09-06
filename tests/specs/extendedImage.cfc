component extends="tests.BaseTest" appMapping="/tests" {
	/**
	* Run tests
	*/
	function beforeAll(){
		super.beforeAll();
	};

	function run(){
		describe( "extendedImage tests", function(){
			beforeEach(function(){
				variables.extendedImage = getInstance( 'models.extendedImage' );
			});

			it( "Can return a memento", function(){
				expect(	extendedImage.getMemento() ).toBeTypeOf( 'struct' );
			});
		});


		describe( "Image tests", function(){
			beforeEach(function(){
				variables.extendedImage = getInstance( 'models.extendedImage' );
			});
			
			it ( "Can recognise no image in object ", function(){
				expect( extendedImage.containsImage() ).toBeFalse;
			});

			it( "Can create an image from text", function(){
				extendedImage.createTextImage(
						textString = 'Testy McTesterson'
				);
				expect( isImage(extendedImage.getImageObject()) ).toBeTrue();
			});

			it( "Can read an image from a URL", function(){
				expect(isImage(extendedImage.readImage('https://placebear.com/600/600.jpg').getImageObject())).toBeTrue();
			});

			it( "Can fail to read an image from a URL - gracefully", function() {
				var badImage = extendedImage.readImage('https://thisShouldFail');
				expect(isImage(badImage.getImageObject())).toBeTrue();
				expect(badImage.getStatus()).toBe('Error');
			});

			it( "Can read an image from the filesystem", function() {
				expect(isImage(extendedImage.readImage(expandPath('.') & '/resources/testImage.jpg').getImageObject())).toBeTrue();
			});

			it( "Can fail to read an image from a filesystem - gracefully", function() {
				var badImage = extendedImage.readImage('c:\thisShouldFail');
				expect(isImage(badImage.getImageObject())).toBeTrue();
				expect(badImage.getStatus()).toBe('Error');
			});

		});

		describe( "Image resizing", function(){
			beforeEach(function(){
				variables.extendedImage = getInstance( 'models.extendedImage' );
			});

			it ( "Can recognise no image in object ", function(){
				extendedImage.resize(800,800);
				expect( isImage(extendedImage.getImageObject()) ).toBeFalse();
				expect( extendedImage.getStatus() ).toBe('Error');
			});

			it ( "Can recognise an image does not require resizing", function(){
				extendedImage
					.setImageObject(imageRead(expandPath('.') & '/resources/testImage.jpg'))
					.resize(800,800);

				expect( isImage(extendedImage.getImageObject()) ).toBeTrue();
				expect( extendedImage.getStatus() ).toBe('Success');
			});

			it ( "Can resize an image", function(){
				extendedImage
					.setImageObject(imageRead(expandPath('.') & '/resources/testImage.jpg'))
					.resize(400,400);

				expect( isImage(extendedImage.getImageObject()) ).toBeTrue();
				expect( extendedImage.getImageObject().width).toBe(400);
				expect( extendedImage.getImageObject().height).toBe(400);
			});
		});
	}
}