$(function(){
	if(document.location.href.match(/sign_in_form/i)){
		return
	}else{
		setTimeout(load_templates, 500);
	}
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
		jug.on("disconnect", function(){ console.log("Disconnected") });
		jug.on("reconnect", function(){ console.log("Reconnecting") });
		jug.on('subscribe_not_allowed', function(data){ console.log("You are not authorized to subscribe to channel: " + data.channel) });
		console.log("setup on for subscribe_not_allowed")
		$(document).ajaxSend(function(e, xhr, options) {
		  xhr.setRequestHeader("X-Juggernaut-Id", jug.sessionID);
		});	
		
}
function init_real3(){		
	for(var i in pub_sub_channels){
		console.log("subscribe to " + pub_sub_channels[i]);
		jug.subscribe(pub_sub_channels[i], function(data){
		  log("data for pub_sub_channel " + pub_sub_channels[i] +": " + data);
			process_realtime(data)
		});
	}
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

