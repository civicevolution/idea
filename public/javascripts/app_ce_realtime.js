$(function(){
		//if(params['rt']){
			setTimeout(load_templates, 100);
		//}
});

function load_templates(){
	$.getScript('/javascripts/pure.js',
		function(){
			//console.log("PURE is loaded, now load and process the templates")
			$('<div id="123123"></div>').appendTo('body').load('/plan/get_templates',null,
				function(){
					//if(params['rt']){
						setTimeout(init_load_juggernaut, 100);
					//}
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
			//console.log("juggernaut log: " + data)
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
		//console.log("subscribe to " + pub_sub_channels[i]);
		jug.subscribe(pub_sub_channels[i], function(data){
		  log("data for pub_sub_channel " + pub_sub_channels[i] +": " + data);
			process_juggernaut_input(data)
		});
	}
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
			//console.log("Update the roster data.roster: " + data.roster)
			//temp.roster = data.roster
			update_presence(data.roster);
			break;
	}
}


var chat_form = $('form.chat_form');

chat_form.bind('ajax:beforeSend', 
	function() {
		$('div#chat_log').append("<p>Me: " + this['msg'].value + "</p>").scrollTop(99999999);
		this['msg'].value = ''
	}
);

chat_form.find('a.cancel').die('click').live('click', 
	function(){	$(this).closest('div.ui-dialog').dialog('destroy').remove(); return false; }
);

//activate_text_counters_grow( form.find('textarea'), 120 )
chat_form.find(' a.cancel').die('click').live('click',
	function(){
		$(this).closest('div.ui-dialog').dialog('destroy').remove();
		return false;
	}
);

var chat_announcement_msg = " is present in this chat";
setTimeout('chat_announcement_msg = " has entered the chat"', 15000);
function update_presence(roster){
	// get list of current ape_codes in the roster
	var new_roster_ape_codes = {};
	for(var mem,i=0;(mem = roster[i]);i++){
		new_roster_ape_codes[mem.ape_code] = mem.name;
		//console.log("roster: ape_code: " + mem.ape_code + " name: " + mem.name);
	}

	// the browser based roster is the images in div#presence
	// go through div#presence and remove any image not in the roster
	var cur_roster_ape_codes = {};
	$('div#presence img').each(
		function(){
			var img = $(this);
			var ape_code = img.attr('id');
			cur_roster_ape_codes[ape_code] = img.attr('title');
			//console.log("check roster for " + ape_code);
			if(!new_roster_ape_codes[ape_code]){
				//console.log("remove this img for apecode: " + ape_code);
				// remove the image
				img.remove();
				// announce member has left in chat
				if(ape_code && ape_code != ''){
					$('div#chat_log').append("<p>" + img.attr('title') + " has left the chat</p>").scrollTop(99999999);
				}
			}
		}
	);
	
	// iterate through the items in the roster update and append anything not in the current roster
	for(var mem,i=0;(mem = roster[i]);i++){
		//console.log("check if this member is in current roster: " + mem.ape_code);
		if(mem.ape_code != '' && !cur_roster_ape_codes[mem.ape_code]){
			//console.log("append new member to roster");
			var new_presence_img = presence_img.clone();
			var src = 'http://s3.amazonaws.com/assets.civicevolution.org/mp/KtUfJMphNeDHNs/36/m.jpg'.replace(/\/mp\/\w*/,'/mp/' + mem.ape_code);
			new_presence_img.attr('title',mem.name);
			new_presence_img.attr('id',mem.ape_code);
			new_presence_img[0].onerror = function(){
				this.src = 'http://2029.civicevolution.dev/images/members_default/36/m.jpg';
			};
			new_presence_img.attr('src',src);
			$('div#presence').append(new_presence_img);
			//console.log("Announce new member presence: " + mem.name);
			$('div#chat_log').append("<p>" + mem.name + chat_announcement_msg + "</p>").scrollTop(99999999);
			
		}
	}
}