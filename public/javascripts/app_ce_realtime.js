$(function(){
		if(params['rt']){
			setTimeout(load_templates, 100);
		}
});

function load_templates(){
	$.getScript('/javascripts/pure.js',
		function(){
			//console.log("PURE is loaded, now load and process the templates")
			$('<div id="123123"></div>').appendTo('body').load('/plan/get_templates',null,
				function(){
					setTimeout(init_load_juggernaut, 100);
				}
			);
		}
	)	
}

var jug;
var log;

function init_load_juggernaut(){
	if( typeof team_id == 'undefined' || team_id == 0 ) return;
	$.getScript('/application.js', 
		function(){
			//console.log("node application.js is loaded");
			setTimeout(init_juggernaut,100);
			//console.log("setTimeout init_juggernaut is set")
		}
	)
}

function custom_subscribe(channel, callback){
  if ( !channel ) throw "Must provide a channel";
	//console.log("Juggernaut.fn.subscribe MODIFIED with member info");
  this.on(channel + ":data", callback);

  var connectCallback = this.proxy(function(){
    var message     = new Juggernaut.Message;
    message.type    = "subscribe";
    message.channel = channel;
		message.name = member.first_name + ' ' + member.last_name.slice(0,1);
		message.ape_code = member.ape_code;
    this.write(message);
  });

  if (this.io.socket.connected)
    connectCallback();
  else {
    this.on("connect", connectCallback);
  }
};


function init_juggernaut(){
		Juggernaut.fn.subscribe = custom_subscribe;
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
			//console.log("call init_subscribe");
			setTimeout(init_juggernaut_subscribe,100);
			//console.log("setTimeout init_juggernaut_subscribe is set")
		});
		jug.on("disconnect", function(){ log("Disconnected") });
		jug.on("reconnect", function(){ log("Reconnecting") });
		
		$(document).ajaxSend(function(e, xhr, options) {
		  xhr.setRequestHeader("X-Juggernaut-Id", jug.sessionID);
		});	
		
}
function init_juggernaut_subscribe(){		
	for(var i in pub_sub_channels){
		console.log("subscribe to " + pub_sub_channels[i]);
		jug.subscribe(pub_sub_channels[i], function(data){
		  log("data for pub_sub_channel " + pub_sub_channels[i] +": " + data);
			process_juggernaut_input(data)
		});
	}
	$.getScript('/chat_form/' + team_id,null,null,'script');	
}

function process_juggernaut_input(data){
	temp.data = data
	switch(data.act){
		case 'update_chat':
			$('div#chat_log').append("<p>" + data.name + ": " + data.msg + "</p>").scrollTop(99999999);
			break;
		case 'update_page':
			//$('div#chat_log').append("<p>Update page with " + data.type + "</p>");
			if(realtime_data_update_functions[data.type]){
				realtime_data_update_functions[data.type](data)	
			}else{
				console.log("Build a function for data type: " + data.type)
			}
			break;
		case 'update_roster':
			console.log("Update the roster data.roster: " + data.roster)
			temp.roster = data.roster
			break;
	}
}

