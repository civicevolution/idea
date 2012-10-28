console.log("Loading new app_ce_realtime.js, get_templates: " + get_templates);
$(function(){
	if(get_templates){
		//console.log("call load_templates A");
		setTimeout(load_templates, 100);
	}else{
	  setTimeout(init_load_juggernaut, 100);
	}
});

function load_templates(){
	//console.log("in load_templates");
	$.getScript('/assets/opt/pure.js',
		function(){
			//console.log("PURE is loaded, now load and process the templates")
			$('<div id="123123"></div>').appendTo('body').load('/idea/get_templates',null,
				function(){
					//console.log("call init_load_juggernaut");
          setTimeout(init_load_juggernaut, 100);
				}
			);
		}
	)	
}

var jug;
var log;

function init_load_juggernaut(){
	//console.log("init_load_juggernaut, pub_sub_channels.length: " + pub_sub_channels.length);
  if(pub_sub_channels.length == 0) return;
  //console.log("init_load_juggernaut proceed");
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
		message.ape_code = {
				ape_code: member.ape_code,
		    jug_id: jug.sessionID,
				ror_session_id: member.ror_session_id
		}
		
    this.write(message);
  });

  if (this.io.socket.connected)
    connectCallback();
  else {
    this.on("connect", connectCallback);
  }
};

function custom_publish(channel, data){
  if ( !channel ){
    console.log("Must provide a channel");
    return;
  } 
  //console.log("custom_publish channel: " + channel);
  var connectCallback = this.proxy(function(){
    var message     = new Juggernaut.Message;
    message.type    = "publish";
    message.channel = channel;
		message.data = data;
		message.data.id = jug.sessionID;
		//message.data.channel = channel;
    this.write(message);
  });

  if (this.io.socket.connected)
    connectCallback();
  else {
    this.on("connect", connectCallback);
  }
};

function init_juggernaut(){
  //console.log("init_juggernaut");
	Juggernaut.fn.subscribe = custom_subscribe;
	Juggernaut.fn.publish = custom_publish;
	log = function(data){
		//console.log("juggernaut log: " + data)
	}
	
	var host = params['host'] || document.location.hostname;
	var port = params['port'] || document.location.port || 80;
	jug = new Juggernaut({
	  secure: ('https:' == document.location.protocol),
	  host: host,
	  port: port
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

var team_channel;
function init_juggernaut_subscribe(){		
	for(var i in pub_sub_channels){
		console.log("subscribe to " + pub_sub_channels[i]);
		jug.subscribe(pub_sub_channels[i], function(data){
		  log("data for pub_sub_channel " + pub_sub_channels[i] +": " + data);
			process_juggernaut_input(data)
		});
		if(pub_sub_channels[i].match(/_team_\d+$/)){
		  team_channel = pub_sub_channels[i];
		}
	}
}

function process_juggernaut_input(data){
	temp.data = data
	switch(data.act){
		case 'update_chat':
			var chat_log = $('div#chat_log');
		  if(chat_log.find('p:last').attr('id') == data.id){
		    chat_log.append('<p id="' + data.id + '" class="cont">' + data.msg + '</p>').scrollTop(99999999);
		  }else{
			  chat_log.append('<p id="' + data.id + '">' + data.name + ": " + data.msg + "</p>").scrollTop(99999999);
			}
		  
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

$('div.activity_chat button').live('click',
  function(){
    send_chat_msg(this);
    return false;
  }
);

$('div.activity_chat input[type="text"]').live('keydown',
  function(event){
    if(event.keyCode == 13) {
      event.preventDefault();
      send_chat_msg(this);
      return false;
    }
  }
);

function send_chat_msg(form_el){
  var form = $(form_el).closest('form');
  //console.log("chat button click");
  var msg = form.find('input#msg');
  var recip_jug_id = form.find('input#jug_id').val();
  jug.publish(team_channel,{act: 'update_chat', name: member.first_name + ' ' + member.last_name.slice(0,1), msg: msg.val(), except: jug.sessionID} );		
  var chat_log = form.closest('div.activity_chat').find('div#chat_log');
  if(chat_log.find('p:last').attr('ape_code') == member.ape_code){
    chat_log.append('<p ape_code="' + member.ape_code + '" class="cont">' + msg.val() + '</p>').scrollTop(99999999);
  }else{
	  chat_log.append('<p ape_code="' + member.ape_code + '">Me: ' + msg.val() + '</p>').scrollTop(99999999);
	}
  msg.val('');
  
  return false;
}

//var chat_form = $('form.chat_form');
//
//chat_form.bind('ajax:beforeSend', 
//	function() {
//		$('div#chat_log').append("<p>Me: " + this['msg'].value + "</p>").scrollTop(99999999);
//		this['msg'].value = ''
//	}
//);
//
//chat_form.find('a.cancel').die('click').live('click', 
//	function(){	$(this).closest('div.ui-dialog').dialog('destroy').remove(); return false; }
//);
//
////activate_text_counters_grow( form.find('textarea'), 120 )
//chat_form.find(' a.cancel').die('click').live('click',
//	function(){
//		$(this).closest('div.ui-dialog').dialog('destroy').remove();
//		return false;
//	}
//);

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
			var src = 'http://s3.amazonaws.com/assets.civicevolution.org/mp/KtUfJMphNeDHNs/small/m.jpg'.replace(/\/mp\/\w*/,'/mp/' + mem.ape_code.ape_code);
			new_presence_img.attr('title',mem.name);
			new_presence_img.attr('id',mem.ape_code);
			new_presence_img[0].onerror = function(){
				this.src = 'http://2029.civicevolution.dev/assets/members_default/small/m.jpg';
			};
			new_presence_img.attr('src',src);
			$('div#presence').append(new_presence_img);
			//console.log("Announce new member presence: " + mem.name);
			$('div#chat_log').append("<p>" + mem.name + chat_announcement_msg + "</p>").scrollTop(99999999);
			
		}
	}
}

//console.log = function(msg){
//	$('div#chat_log').append("<p>" + msg + "</p>").scrollTop(99999999);
//}