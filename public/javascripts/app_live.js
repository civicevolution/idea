$(function(){
	setTimeout(load_templates, 500);
});

function load_templates(){
	$.getScript('/javascripts/pure.js',
		function(){
			console.log("PURE is loaded, now load and process the templates")
			$('<div id="123123"></div>').appendTo('body').load('/live/get_templates',null,
				function(){
					setTimeout(init_realtime, 100);
				}
			);
		}
	)	
}

var jug;
var log;

function init_realtime(){
	//if( typeof team_id == 'undefined' || team_id == 0 ) return;
	$.getScript('/application.js', 
		function(){
			console.log("node application.js is loaded");
			setTimeout(init_real2,100);
			console.log("setTimeout init_real2 is set")
		}
	)
}
function init_real2(){
		log = function(data){
			console.log("juggernaut log: " + data)
		}

		jug = new Juggernaut({
		  secure: ('https:' == document.location.protocol),
		  host: document.location.hostname,
		  port: document.location.port || 80
		});

		jug.on("connect", function(){ 
			log("Connected");
			console.log("call init_real3");
			setTimeout(init_real3,100);
			console.log("setTimeout init_real3 is set")
		});
		jug.on("disconnect", function(){ log("Disconnected") });
		jug.on("reconnect", function(){ log("Reconnecting") });
		
		$(document).ajaxSend(function(e, xhr, options) {
		  xhr.setRequestHeader("X-Juggernaut-Id", jug.sessionID);
		});	
		
}
function init_real3(){		
		ch = params['ch']
		console.log("subscribe_to_team_channel: Subscribing to " + ch);
		jug.subscribe(ch, function(data){
		  log("data: " + data);
			process_realtime(data)
		});
		//$.getScript('/chat_form/' + ch,null,null,'script');
}
function process_realtime(data){
	console.log("process_realtime act: " + data.act)
	temp.data = data
	switch(data.act){
		case 'update_chat':
			$('div#chat_log').append("<p>" + data.name + ": " + data.msg + "</p>").scrollTop(99999999);
			break;
		case 'theming':
			if(realtime_data_update_functions[data.type]){
				realtime_data_update_functions[data.type](data)	
			}else{
				console.log("Build a function for data type: " + data.type)
			}
			break;
	}
}

