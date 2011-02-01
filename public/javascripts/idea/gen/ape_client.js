//APE.Shoutbox = new Class({

APE.Shoutbox = APE.Client.extend({	

	initialize: function(container){
		this.els = {};
		//console.log("APE.Shoutbox.initialize() with container: " + container)

		//Start the shoutbox once ape is loaded
		this.addEvent('load', this.start);

		//Shoutbox container
		this.els.container = $('#' + container);
		this.chat_container = $('#' + container);
		//this.setEvents.bind(this);
		this.setEvents()
		
	},
	
	setEvents: function(){
			//console.log("setEvents");
			//Catch pipeCreate events when you join a channel
			this.addEvent('multiPipeCreate', this.initChatWindows);

			////Catch message sending
			//this.onCmd('send',this.cmdSend);

			//Catch message reception
			this.onRaw('data',this.rawData);
			this.onRaw('close',this.apeRecordClose);

			//Catch error reception
			this.onRaw('ERR',this.rawErr);
			this.onRaw('login',this.rawLogin);

			//Catch message reception
			this.onRaw('rating',this.showRating);
			this.onRaw('com_rate',this.showComRating);
			this.onRaw('ans_json',this.showAnswerJson);
			this.onRaw('com_json',this.showCommentJson);
	//		this.onRaw('item_json',this.dispatchItems);
			this.onRaw('list_item_json',this.showListItemJson);
			this.onRaw('reorder_list_item_json',this.reorderListItemJson);
			this.onRaw('chat',this.dispatchChat);

			this.onRaw('bs_idea',this.dispatchIdeas);

			//this.addEvent('userJoin', this.createUser);
			this.addEvent('userLeft', this.deleteUser);
			this.onRaw('channel',this.initChannelUsers);
			
			this.addEvent('onRaw', this.resetWatchDogTimer);
			
	//		this.onError('004', this.reset);
	
			this.fast_close_counter = 0;
			this.last_close_time = 0;
	},

	start: function() {
		this.nickname = member.ape_code;
		//console.log("ape client.start for nickname: " + this.nickname)
		//Call start method from core to start connection to APE server
		this.core.start({'name': this.nickname});
	},
	
	quit: function (){
		this.core.quit();
	},
	quit_immediately: function(){
		try{
			//console.log("quit_immediately as page unloads to free up the nick v1");
			var ape = member.client.core.transport.ape
			var options = ape.options
			var url = 'http://' + options.frequency + '.' + options.server + '/'+options.transport+'/?' +
				'[{%22cmd%22:%22QUIT%22,%22chl%22:' +
				(ape.request.chl + 10) +
				',%22sessid%22:%22' + member.client.core.sessid + '%22}]';
				//console.log("url: " + url )
				member.client.quit_completed = false;
				var req = $.ajax({
				  url: url,
					async: false
				});
			member.client.core.clearSession();
			//console.log("QUIT has been completed successfully")
		}catch(e){
			// this can fail if there is no current ape session, just ignore it as I am signing out anyway
		}
	},	

	initChatWindows:function(pipe, options){
		//console.log("initChatWindows pipe: " + pipe)
		this.pipe = pipe;
		if(this.addedPageChannel){
			//console.log("page channel has been added")
		}else{
			//console.log("call activateChatWindows")
			activateChatWindows(this.chat_container);
			if(page_channel){
				//console.log("join another channel: " + page_channel)
				this.core.join(page_channel)
				this.addedPageChannel = true;
			}		
		}
		//this.chatWindows = createChatWindows(this)
	},

	///***
	// * Intercepts the send messages and the message in the shoutbox
	// */
	//cmdSend: function(param,pipe) {
	//	//console.log("cmdSend")
	//	this.writeMessage(param.msg, this.core.user.properties.name);
	//},

	/***
	 * Intercepts the raw data and messages the message in the shoutbox
	 */
	rawData: function(raw, pipe){
		//debugger
		try{
			//temp.rawData = raw
			//console.log("rawData raw.data.msg: " + raw.data.msg)
			if(raw.data.msg.match(/\d+-\w+/)){
				NOTIFIER.inform( { 
					type: 'presence',
					page_id: raw.data.msg.match(/^(\d+)-/)[1],
					ape_code: raw.data.msg.match(/-(\w{14}).*$/)[1]
 				});
			}
			//this.writeMessage(raw.data.msg, raw.data.from.properties.name);
		}catch(e){console.log("rawData.error e: " + e)}
	},
	apeRecordClose: function(raw,pipe){
		//if(location.host.match(/dev$/)){
	  //	console.log("apeRecordClose: ape close was received, time: " + raw.time + ', this.last_close_time: ' + this.last_close_time + ', this.fast_close_counter: ' + this.fast_close_counter);
		//}
		if(raw.time - this.last_close_time > 5 ){
			this.fast_close_counter = 0;
		}else{
			++this.fast_close_counter;
			if(this.fast_close_counter > 3){
				this.fast_close_counter = 0;
				console.log("apeRecordClose CALL reconnect fast_close_counter: " + this.fast_close_counter );
				if(location.host.match(/dev$/)){
					// show a dialog
					if( $('div#runaway_dialog').size() == 0){
						var dialog = $('<div id="runaway_dialog">APE was reset because of runaway posting</div>').dialog( {title : 'APE warning', modal : true } )
					}
				}
				// tell the server, one time
				if(!temp.ape_runaway_notified){
					$.post('/client_debug/ape_report', {browser: navigator.userAgent, failure: 'race_restart v1'})
					temp.ape_runaway_notified = true
				}
				this.reconnect();
			}			
		}
		this.last_close_time = raw.time
	},
	resetWatchDogTimer: function(){
		//console.log("clearTimeout(apeResetWatchDog)")
		//clearTimeout(apeResetWatchDog);
		//apeResetWatchDog = setTimeout(reinitializeApe,90000);
	},
	rawLogin: function(raw,pipe){
		//console.log("rawLogin response handler - store sessid and start polling");
		this.core.sessid = raw.data.sessid;
		//console.log("rawLogin, this.core.sessid: " + this.core.sessid )
		this.core.startPoller();
		this.core.poller();
		
	},
	rawErr: function(err,pipe){
		//console.log("rawErr: err.data.value: " + err.data.value + ", code: " + err.data.code)
		
		if(err.data.code=='004'){ // BAD_SESSID
			console.log("ape client.rawErr, BAD_SESSID");
			this.reconnect();
		}		
		
		if(err.data.code=='007'){
			console.log("ape client.rawErr, this nickname is taken: " + this.nickname)
			//console.log("add a random prefix to my nickname and try again")
			this.nickname = member.ape_code + Math.round(Math.random()*100)
			this.reconnect();
		}
	},
	reconnect: function(){
		console.log("reconnect")
		this.core.clearSession();
		setTimeout(member.client.reconnect_restart, 5000)
	},
	reconnect_restart: function(){
		console.log("reconnect_restart with NICK: " + member.client.nickname)
		member.client.setEvents(); // re-init events
		member.client.core.start( {'name': member.client.nickname}); // start after clear session will send CONNECT/JOIN
	},
	showRating: function(rating,pipe){
		dispatchRating(rating)
	},
	
	showComRating: function(rating,pipe){
		//console.log("showComRating")
		dispatchComRating(rating)				
	},
	
	showCommentJson: function(item,pipe){
		dispatchComment(item.data);
	},	

	showAnswerJson: function(item,pipe){
		dispatchAnswer(item.data);
	},	

	showListItemJson: function(item,pipe){
		//console.log("showListItemJson")
		insert_update_list_item_json(item);
	},

	reorderListItemJson: function(item,pipe){
		//console.log("reorder_list_item_json this")
		reorder_list_item_json(item);
	},
	
	dispatchChat: function(chat,pipe){
		dispatchPageChatMessage(chat);
	},	
	
	dispatchIdeas: function(idea,pipe){
		dispatchBsIdeas(idea.data);
	},
	dispatchItems: function (item,pipe){
		dispatchItem(item)
	},
	
	initChannelUsers: function(data,pipe){
		// now that I am in the team channel, tell them what page I am on
		//console.log("I just inited the channel, I will announce myself");
		announce_page_presence()
		//temp.initChannelUsers_data = data
		////console.log("initChannelUsers update online list");
		//mem_online = $('div#members_online');
		//$('div.ape_user',mem_online).remove();
		//var p_end = $('p.clear_both',mem_online);
		//$.each( data.data.users,
		//	function(){
		//		var name = this.properties.name.match(/\w{14}/);
		//		//console.log("add member to online: " + name);
		//		var mem = $('div#team_members_roster div.ape_user[ape_code="' + name + '"]')
		//		if(mem.size()>0){
		//			mem = mem.clone();
		//			mem.attr('create_count', 1 )
		//			mem.find('span').remove();
		//			p_end.before(mem)
		//			// add the cluetip to the member
		//			mem.attr({href:'#ape_user_online', rel: '#ape_user_online', title: 'Team member details'}).cluetip(
		//			  {local: true, 
		//			  hideLocal: true, 
		//			  cursor: 'pointer',
		//			  onActivate: NOTIFIER.report_member_details}
		//			);					
		//		}				
		//	}
		//);
	},
	
	createUser: function(user, pipe){
		var name = user.properties.name.match(/\w{14}/);
		//console.log("v2 createUser, name: " + name);
		// if this member is already in div#members_online, increment create_count
		var mem = $('div#members_online div.ape_user[ape_code="' + name + '"]');
		if(mem.size() > 0){
			// already shown online, increment count
			mem.attr('create_count', Number(mem.attr('create_count')) + 1 )
		}else{
			var mem = $('div#team_members_roster div.ape_user[ape_code="' + name + '"]')
			if(mem.size()>0){
				mem = mem.clone();
				mem.attr('create_count', Number(mem.attr('create_count')) + 1 )
				mem.find('span').remove();
				$('div#members_online p.clear_both').before(mem)
				
				// add the cluetip to the member
				mem.attr({href:'#ape_user_online', rel: '#ape_user_online', title: 'Team member details'}).cluetip(
				  {local: true, 
				  hideLocal: true, 
				  cursor: 'pointer',
				  onActivate: NOTIFIER.report_member_details}
				);
			}
		}
	},

	deleteUser: function(user, pipe){
		// remove this participant from div#members_online
		var name = user.properties.name.match(/\w{14}/);
		console.log("v2 deleteUser name: " + name )
		//var mem = $('div#members_online div.ape_user[ape_code="' + name + '"]')
		//if(mem.size()>0){
		//	if(Number(mem.attr('create_count')) == 1){
		//		// member online JOINed once, so 1 LEFT means they are gone
		//		mem.cluetip('destroy');
		//		mem.remove();
		//	}else{
		//		// member must have JOINed from multiple computers, so decrement count for this LEFT
		//		mem.attr('create_count', Number(mem.attr('create_count')) - 1 );				
		//	}
		//}
		// remove this user from page presence
		NOTIFIER.inform( { 
			type: 'presence',
			ape_code: name
		});
		// if this user is leaving and shares the same ape code as me (an alias) I need to reannounce myself
		if( name == member.ape_code && member.client.nickname != user.properties.name){
			announce_page_presence()
		}
	}
	
});
