<!---
*******************************************************************************
Coldthumbs
Copyright 2018 - Simian Enterprises Ltd.
www.simianenterprises.co.uk
*******************************************************************************
Author: Gary Stanton 
Twitter: @SimianE
--->

<!doctype html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

		<!-- Bootstrap CSS -->
		<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.1/css/bootstrap.min.css" integrity="sha384-WskhaSGFgHYWDcbwN70/dfYBj47jz9qbsMId/iRN3ewGhXQFZCSftd1LZCfmhktB" crossorigin="anonymous">
		<link rel="stylesheet" href="monokai.css">

		<title>ColdThumbs v2</title>
		<style type="text/css">
			iframe {
				position: absolute;
				top: 0;
				bottom: 0;
				left: 0;
				right: 0;
				height: 100%;
				width: 100%;
			}

			.threads {
				overflow: hidden;
				height: 800px;
			}
		</style>
	    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>

		<script type="text/javascript">
			function checkImage(imageSrc, imageSuccess, imageFail) {
				var img 	= new Image();
				img.onload 	= imageSuccess; 
				img.onerror = imageFail;
				img.src 	= imageSrc;
			}

			$(document).ready(function() {
				$('img.lazy').each(function(){
					var thisImage 		= $(this);
					var thisSrc 		= $(this).attr('data-src');
					var imageSuccess 	= function(){$(thisImage).attr('src', thisSrc);}
					var imageFail 		= function(){
						$(thisImage).attr('src', 'demo/Placeholder.png');
						setTimeout(function(){
							checkImage(thisSrc, imageSuccess, imageFail);
						}, 1000);
					}
					checkImage(thisSrc, imageSuccess, imageFail);
				});
			});

		</script>
	</head>
	
	<body>
		<cfoutput>

    	<main role="main">

			<div class="jumbotron">
				<div class="container">
					<h1 class="display-3">ColdThumbs</h1>
					<p>A ColdFusion component to dynamically resize and cache images.</p>
				</div>
			</div>

			<div class="container">

				<nav class="navbar navbar-expand-sm navbar-dark fixed-top bg-dark">
					<a class="navbar-brand" href="##">ColdThumbs</a>
					<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="##mainNav" aria-controls="mainNav" aria-expanded="false" aria-label="Toggle navigation">
						<span class="navbar-toggler-icon"></span>
					</button>
					<div class="collapse navbar-collapse" id="mainNav">
						<ul class="navbar-nav mr-auto">
							<li class="nav-item active">
								<a class="nav-link" href="">Home</a>
							</li>
							<li class="nav-item">
								<a class="nav-link" href="#fileExists(getDirectoryFromPath( getCurrentTemplatePath() ) & 'docs/index.html') ? 'docs/' : 'generateDocs.cfm'#">API Docs</a>
							</li>
							<li class="nav-item">
								<a class="nav-link" href="tests/runner.cfm">Tests</a>
							</li>
						</ul>
					</div>
				</nav>

				<div class="row">
					<div class="images text-center col-md-6">
						<div class="row">
							<cfscript>
								Local.images = directoryList(expandPath('./demo/assets/'));
								for (Local.thisImage in Local.images) {
									if (ArrayFindNoCase(Application.com.ColdThumbs.getAllowedExtensions(), ListLast(Local.thisImage, '.'))) {
										Local.testImage = Application.com.coldThumbs.getThumbnail(
												src						= Local.thisImage
											,	width					= 300
										);

										writeOutput('
										<div class="col-6 control-group">
											<img class="lazy img-fluid img-thumbnail" src="/demo/placeholder.png" data-src="#Local.testImage.getURL()#" alt="#Local.testImage.getFilename()#">
											<br />
											<code>#Local.testImage.getURL()#</code>
											<hr />
										</div>');
									}
								}
							</cfscript>
						</div>
					</div>

					<div class="threads col-md-5 offset-md-1">
						<a href="actClearCache.cfm" class="float-right btn btn-info">Clear cached files</a>

						<div>
						<h3>ColdThumbs settings</h3>
						<hr />
						<table class="table table-sm table-dark table-sm">
							<tbody>
								<tr>
									<th scope="row">Threading</th>
									<td>#YesNoFormat(Application.com.coldThumbs.getUseThreading())#</td>
								</tr>
								<tr>
									<th scope="row">Threading system</th>
									<td>#IsInstanceOf(Application.com.coldThumbs.getExecutorService(), 'cfconcurrent.ExecutorService') ? 'CFConcurrent' : 'Native CF'#</td>
								</tr>
								<tr>
									<th scope="row">Max threads</th>
									<td>#Application.com.coldThumbs.getMaxThreads()#</td>
								</tr>
								<tr>
									<th scope="row">Image resizing</th>
									<td>#(len(Application.com.coldThumbs.getImageMagickLocation()) && fileExists(Application.com.coldThumbs.getImageMagickLocation())) ? 'ImageMagick' : 'Native'#</td>
								</tr>
							</tbody>
						</table>
						</div>
						<div class="embed-responsive">
							<hr />
						  	<iframe class="embed-responsive-item" style="width: 100%; height: 800px; position: relative;" src="viewThreads.cfm" allowfullscreen></iframe>
						</div>
					</div>
				</div>

			</div>
		</main>

	    <footer class="container">
	      <p>&copy; Gary Stanton #DateFormat(Now(), 'yyyy')#</p>
	    </footer>


	    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>
	    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.1/js/bootstrap.min.js" integrity="sha384-smHYKdLADwkXOn1EmN1qk/HfnUcbVRZyYmZ4qpPea6sjB/pTJ0euyQp0Mk8ck+5T" crossorigin="anonymous"></script>
	    <script src="https://cdn.rawgit.com/google/code-prettify/master/loader/run_prettify.js"></script>

	</cfoutput>
	</body>
</html>
