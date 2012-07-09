//console.log("loading app_live_realtime.js");
$(function(){
	if(get_templates){
		setTimeout(load_templates, 100);
	}else{
	  setTimeout(init_load_juggernaut, 100);
	}
});

function load_templates(){
	$.getScript('/javascripts/pure.js',
		function(){
			//console.log("PURE is loaded, now load and process the templates")
			$('<div id="123123"></div>').appendTo('body').load('/live/get_templates',null,
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
  if(pub_sub_channels.length == 0) return;
  //console.log("init_load_juggernaut");
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
		message.name = node.username;
		message.ape_code = {
		    node_id: node.id,
		    jug_id: jug.sessionID,
		    role: node.role,
				browser: $.browser,
				height: $(window).height(), 
				width: $(window).width(),
				href: document.location.href
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
		$.get('/live/jug_id');
}
var event_channel;
var theme_channel;
function init_juggernaut_subscribe(){		
  //console.log("init_juggernaut_subscribe with jug.sessionID: " + jug.sessionID);
	for(var i in pub_sub_channels){
		//console.log("subscribe to " + pub_sub_channels[i]);
		jug.subscribe(pub_sub_channels[i], function(data){
		  log("data for pub_sub_channel " + pub_sub_channels[i] +": " + data);
			process_juggernaut_input(data)
		});
		if(pub_sub_channels[i].match(/_event_\d+$/)){
		  event_channel = pub_sub_channels[i];
		}
		
		if(pub_sub_channels[i].match(/parent/)){
		  theme_channel = pub_sub_channels[i];
		  $(':input[id="theme_channel"]').val(theme_channel);
		}
	}
	
	setTimeout(report_status,10);
	
	if(params['test']){
  	console.log("autostart the test in init_juggernaut_subscribe")
  	// auto start the test  for 30 seconds
    setTimeout( "$('div.test_mode :submit').click()", 2000);
    //setTimeout( "$('div.test_mode a.stop_test').click()", 30000);
  }
}

function process_juggernaut_input(data){
	temp.data = data;
	switch(data.act){
	  case 'theming':
			if(realtime_data_update_functions[data.type]){
				realtime_data_update_functions[data.type](data)	
			}else{
				console.log("Build a function for data type: " + data.type)
			}
			break;
		
		case 'update_chat':
		  if(update_chat){update_chat(data);}
			break;
		case 'update_page':
			if(realtime_data_update_functions[data.type]){
				realtime_data_update_functions[data.type](data)	
			}else{
				console.log("Build a function for data type: " + data.type)
			}
			break;
		case 'update_roster':
			//console.log("Update the roster data.roster: " + data.roster)
			temp.roster = data.roster
			update_presence(data.roster);
			break;
		case 'change_page_url':
		  if(node.role=='scribe'){
		    //console.log("change_page_url to url: " + data.url);
		    document.location.href = '/live/scribe?dest=' + data.url
		  }else{
		    //console.log("ignore change_page_url");
		  }
		  break;
		case 'test_publish':
		  console.log("test_publish with message: " + data.message);
		  break;
		case 'status_report':
		  //console.log("STATUS REPORT jug_id: " + data.message.jug_id + " is " + data.message.status + " as " + data.message.role);
		  if(update_status_report){
		    update_status_report(data.message);
		  }
		  break;
		default:
		  console.log("NO ACTION defined for process_juggernaut_input for act: " + data.act);
	}
}

var dispatcher_jug_ids = [];
var themer_parent_jug_id;
var update_roster = ($('div.dispatch_page').size() > 0);
function update_presence(roster){
  //console.log("update_presence for roster");
	//if(update_roster) $('td.page').addClass('warn').html('Disconnected');
	if(update_roster) $('td.page').addClass('unverified');
	for(var mem,i=0;(mem = roster[i]);i++){
	  //console.log("process roster mem.ape_code.node_id: " + mem.ape_code.node_id + ", mem.ape_code.role: " + mem.ape_code.role +", node.parent_id: " + node.parent_id);
	  if(mem.ape_code.role == 'dispatcher'){
	    //console.log("add to dispatcher_jug_ids: " + mem.ape_code.jug_id);
	    dispatcher_jug_ids.push( mem.ape_code.jug_id );
	    $.unique(dispatcher_jug_ids);
	    setTimeout(report_status,10);
	  }
	  if(mem.ape_code.node_id == node.parent_id){
	    //console.log("add to themer_parent_jug_id: " + mem.ape_code.jug_id);
	    themer_parent_jug_id = mem.ape_code.jug_id;
	    $('div.chat.parent input#jug_id').val(themer_parent_jug_id);
	    setTimeout(report_status,10);
	  }
	  
	  if(update_roster){
  	  var tr = $('tr[id="' + mem.name + '"]');
  	  //var href = mem.ape_code.href;
  	  //var page = href.match(/dest=/) ? href.match(/dest=(.*)/)[1] : 'home';
  	  //tr.find('td.page').removeClass('warn').html( page ); 
  	  tr.attr('jug_id', mem.ape_code.jug_id ); 
  	  tr.attr('last_update_ctr',0);
  	  tr.find('td.page').removeClass('unverified');
  	}
  }
  if(update_roster) $('td.page.unverified').addClass('warn').html('Disconnected').parent().find('td.activity').html('');
}

function report_status(){
  //console.log("report_status");
  var recipient_jug_ids = dispatcher_jug_ids.concat( themer_parent_jug_id );
  if(recipient_jug_ids.length>0){
    // get the activity status depending on the page
    var activity = 'n/a';
    switch(page_data.type){
      case 'enter talking points':
        activity = $('div.live_talking_point').size() + ' talking points';
        break;
      case 'allocate':
        activity = ($('a.retrieve_voter').size()-1) + ' voters recorded';
        break;
      case 'micro theming':
        activity = 
          $('div.live_talking_point').size() + ' incoming talking points<br/>' +
          $('div.list_column div.theme').size() + ' themes<br/>' +
          $('div.list_column div.idea').size() + ' themed talking points<br/>' +
          $('div.list_column div.example').size() + ' example talking points';
        break;
      case 'macro theming':
        activity = 
          $('div.live_talking_point').size() + ' incoming micro themes<br/>' +
          $('div.list_column div.theme').size() + ' macro themes<br/>' +
          $('div.list_column div.idea').size() + ' themed micro themes<br/>';
        break;
      case 'coord home page':
        activity = 'home page';
        break;
      case 'final edit themes':
        activity = 'final theme editing';
        break;
      case 'view final themes':
        activity = 'view final themes';
        break;
      case 'session allocation results':
        activity = 'view allocation results';
        break;
      case 'dispatcher home page':
        activity = 'dispatcher home page';
        break;
      case 'reporter home page':
        activity = 'reporter home page';
        break;
      default:
        console.log("XXXXXX determine activity for " + page_data.type);
      
    }
    
    
    var status_message = {
		    jug_id: jug.sessionID,
		    status: 'active',
		    node_id: node.id,
		    role: node.role,
		    name: node.name,
				browser: $.browser,
				height: $(window).height(), 
				width: $(window).width(),
				href: document.location.href,
				page_type: page_data, 
				activity: activity
		}
		
    jug.publish(event_channel,{act: 'status_report', message: status_message, only: recipient_jug_ids });		
  }
  setTimeout(report_status,10000);
}

//function send_chat_msg(recipient_jug_ids, message){
//  console.log("send_chat_msg");
//  jug.publish(event_channel,{act: 'update_chat', name: node.name, msg: message, only: recipient_jug_ids} );		
//}



$('div.chat input[type="button"]').live('click',
  function(){
    send_chat_msg(this);
    return false;
  }
);

$('div.chat input[type="text"]').live('keydown',
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
  jug.publish(event_channel,{act: 'update_chat', name: node.name, node_id: node.id, msg: msg.val(), only: recip_jug_id} );		
  var chat_log = form.closest('div.chat').find('div.chat_log');
  if(chat_log.find('p:last').attr('node_id') == node.id){
    chat_log.append('<p node_id="' + node.id + '">' + msg.val() + '</p>').scrollTop(99999999);
  }else{
	  chat_log.append('<p node_id="' + node.id + '">Me: ' + msg.val() + '</p>').scrollTop(99999999);
	}
  msg.val('');
  
  return false;
}

