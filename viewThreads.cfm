<!doctype html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

		<!-- Bootstrap CSS -->
		<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.1/css/bootstrap.min.css" integrity="sha384-WskhaSGFgHYWDcbwN70/dfYBj47jz9qbsMId/iRN3ewGhXQFZCSftd1LZCfmhktB" crossorigin="anonymous">

		<title>ColdThumbs v2</title>
	</head>
	
	<body>
		<div class="row">
			<div class="col-12">
				<cfoutput>
					<h3>Threads</h3>
					<hr />

					<div class="card">
						<div class="card-header">
							Running
						</div>
						<ul class="list-group list-group-flush">
							<cfloop collection="#Application.com.ColdThumbs.getRunningThreads()#" item="ThisRunningThread">
								<li class="list-group-item">#ThisRunningThread#</li>
							</cfloop>
						</ul>
					</div>

					<hr />

					<div class="card">
						<div class="card-header">
							Queued
						</div>
						<ul class="list-group list-group-flush">
							<cfloop collection="#Application.com.ColdThumbs.getQueuedThreads()#" item="ThisQueuedThread">
								<li class="list-group-item">#ThisQueuedThread#</li>
							</cfloop>
						</ul>
					</div>

				</cfoutput>
			</div>
		</div>

		
		<script type="text/javascript">
		    setTimeout(function () { 
		      location.reload();
		    }, 2 * 1000);
		</script>
	</body>
</html>