/***
 * APE JSF Setup
 */

//APE.Config.baseUrl = 'http://dev-proxy:3000/javascripts/APE-Source/'; //APE JSF 
APE.Config.baseUrl = 'http://' + document.location.host + '/javascripts/APE-Source/'; //APE JSF 
//APE.Config.domain = 'dev-proxy.com'; 
APE.Config.domain = document.location.host; 
//APE.Config.server = 'ape.dev-proxy.com:6969'; //APE server URL
APE.Config.server = 'ape.civicevolution.org'; //APE server URL
APE.Config.transport = 2;  // 2 is JSONP

(function(){
	for (var i = 0; i < arguments.length; i++)
		APE.Config.scripts.push(APE.Config.baseUrl + arguments[i] + '.js');
})('mootools-core', 'Core/APE', 'Core/Events', 'Core/Core', 'Pipe/Pipe', 'Pipe/PipeProxy', 'Pipe/PipeMulti', 'Pipe/PipeSingle', 'Request/Request','Request/Request.Stack', 'Request/Request.CycledStack', 'Transport/Transport.longPolling','Transport/Transport.SSE', 'Transport/Transport.XHRStreaming', 'Transport/Transport.JSONP', 'Core/Utility', 'Core/JSON');
