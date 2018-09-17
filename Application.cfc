/**
*******************************************************************************
* Coldthumbs
* Copyright 2018 - Simian Enterprises Ltd.
* www.simianenterprises.co.uk
*******************************************************************************
* @author Gary Stanton 
*/

component{
	this.name 					= hash( getCurrentTemplatePath() );
	this.mappings[ '/docbox' ]  = getDirectoryFromPath( getCurrentTemplatePath() ) & 'docbox/';
	this.mappings[ '/models' ]  = getDirectoryFromPath( getCurrentTemplatePath() ) & 'models/';

	public boolean function onApplicationStart(){
		Application.executorService = createObject("component", "cfconcurrent.ExecutorService")
			.init( serviceName = "executorServiceExample", maxConcurrent = 2, maxWorkQueueSize = 100000);
		Application.executorService.setLoggingEnabled( true );
		Application.executorService.start();

		Application.com.coldThumbs = new models.coldThumbs()
			.setMaxThreads(2)
			.setExecutorService(Application.executorService)
			.setImageMagickLocation("C:\Program Files\ImageMagick-7.0.8-Q16\magick.exe");
		return true;
	}

	public boolean function onRequestStart( string targetPage ){
		if (structKeyExists(URL, 'reinit')) {
			applicationStop();
			onApplicationStop();
			location(url = '/', addtoken = false);
		}

		if (structKeyExists(URL, 'IM')) {
			lock timeout="5" scope="Application" type="exclusive" {
				Application.com.ColdThumbs.setImageMagickLocation(URL.IM ? "C:\Program Files\ImageMagick-7.0.8-Q16\magick.exe" : '');
			}
		}

		if (structKeyExists(URL, 'Con')) {
			lock timeout="5" scope="Application" type="exclusive" {
				if (URL.con) {
					Application.com.coldThumbs = new models.coldThumbs()
						.setMaxThreads(Application.com.coldThumbs.getMaxThreads())
						.setExecutorService(Application.executorService)
						.setImageMagickLocation(Application.com.coldThumbs.getImageMagickLocation());
				} 
				else {
					Application.com.coldThumbs = new models.coldThumbs()
						.setMaxThreads(Application.com.coldThumbs.getMaxThreads())
						.setImageMagickLocation(Application.com.coldThumbs.getImageMagickLocation());
				}

			}
		}

		if (structKeyExists(URL, 'Threads') AND isNumeric(URL.Threads)) {
			lock timeout="5" scope="Application" type="exclusive" {
				Application.com.ColdThumbs.setMaxThreads(URL.Threads);
			}
		}

		return true;
	}

	function onApplicationStop(){
		if (StructKeyExists(Application, 'executorService')) {
			Application.executorService.stop();
		}
	}

	function onError(e) {
		writeDump(e);
	}
}
