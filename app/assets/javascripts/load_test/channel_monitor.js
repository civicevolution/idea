console.log("loading channel_monitor.js");
console.log("Using channel (?ch=): " + pub_sub_channels);
node.name = "channel_monitor";
node.username = "channel_monitor";
var incoming_message_ctr = 0;
var logging_on = true;

var load_test_jug_id;
function process_juggernaut_input(data){
	//console.log("process jug input ch mo");
	if(data.act == 'update_roster'){
		for(var mem,i=0;(mem = data.roster[i]);i++){
			//console.log("mem.name: " + mem.name);
		  if(mem.name == 'load_test'){
				load_test_jug_id = mem.ape_code.jug_id;
				//console.log("load_test_jug_id: " + load_test_jug_id);
		  }
		}
	}
	var data_string = JSON.stringify(data);
	if(data.act == 'load test stats'){
		var load_row = $('tr.load');
		load_row.find('td.latency').html( ( new Date().getTime() - data.time_sent ) + ' ms' );
		load_row.find('td.conns span').html( data.connections );
		load_row.find('td.msg_int span').html( data.message_interval );
		load_row.find('td.rss').html(  Math.round(data.memoryUsage.rss/1e6) + 'M' );
		load_row.find('td.heapTotal').html( Math.round(data.memoryUsage.heapTotal/1e6) + 'M' );
    load_row.find('td.heapUsed').html( Math.round(data.memoryUsage.heapUsed/1e6) + 'M' );
    load_row.find('td.uptime').html( data.uptime );
    load_row.find('td.pid').html( data.pid );
		var load = [];
		$.each( data.load_avg, 
			function(i,v){
				load.push( Math.round(v*100)/100 );
			}
		);
		load_row.find('td.loadavg').html( '[ ' + load.join(', ') + ' ]' );
		
	}
	if(data.act == 'juggernaut stats'){
		//console.log(" new Date().getTime() - data.time_sent = latency: " + new Date().getTime() + ' - ' + data.time_sent + ' = ' + ( new Date().getTime() - data.time_sent ) );
		var jug_row = $('tr.jug');
		jug_row.find('td.latency').html( ( new Date().getTime() - data.time_sent ) + ' ms' );
		jug_row.find('td.conns').html( data.namespace_conns );
		jug_row.find('td.msgs').html( data.messages_sent );
		jug_row.find('td.msgs_sec').html( (Math.round(data.messages_per_sec*10)/10) );
		jug_row.find('td.rss').html( Math.round(data.memoryUsage.rss/1e6) + 'M' );
		jug_row.find('td.heapTotal').html( Math.round(data.memoryUsage.heapTotal/1e6) + 'M' );
    jug_row.find('td.heapUsed').html( Math.round(data.memoryUsage.heapUsed/1e6) + 'M' );
    jug_row.find('td.uptime').html( data.uptime );
    jug_row.find('td.pid').html( data.pid );

		var load = [];
		$.each( data.load_avg, 
			function(i,v){
				load.push( Math.round(v*100)/100 );
			}
		);
		jug_row.find('td.loadavg').html( '[ ' + load.join(', ') + ' ]' );


		$('span.num_jug_clients').html( data.clients.length );
		var jug_clients = $('table.jug_clients').html('');
		for(var i=0,client; (client= data.clients[i]); i++){
			jug_clients.append('<tr><td>' + (i + 1) + '</td><td>'  + client.name + '</td><td>' + client.session_id + '</td></tr>');
			if(client.name == 'load_test'){ load_test_jug_id = client.session_id;}
		}
		
		var log_size = $('div#channel_log *').size();
		if( log_size > 100){
			$('div#channel_log *').slice(0,log_size-100).remove()
		}


	}
	
	if(logging_on){
		$('div#channel_log').append("<p>" + data_string + "</p>").scrollTop(99999999);
	}
	$('span.message_ctr').html( ++incoming_message_ctr );
}
function report_status(){console.log("don't report status");}



$('button.toggle_log').live('click',
	function(){
		var btn = $(this);
		if(btn.html().match(/start/i)){
			btn.html('Stop log');
			logging_on = true;
		}else{
			btn.html('Start log');
			logging_on = false;
		}
	}
);

$('button.clear_log').live('click',
	function(){
		$('div#channel_log').html('');
	}
);
$('button.jug_stats').live('click',
	function(){
		request_juggernaut_stats();
	}
);
$('button.load_stats').live('click',
	function(){
		request_load_test_stats();
	}
);
$('a.adj_num_cons').live('click',
	function(){
		var num = prompt("Enter # of connections to run: ");
		if(isNaN(num)){
			alert('Please enter a number. You entered ' + num);
		}else{
			if(load_test_jug_id){
				var event_channel = '_event_2';
				jug.publish(event_channel,{act: 'set_load_connections', num_connections: num, only: load_test_jug_id} );		
				console.log("set load connections to " + num);
		  }else{
				console.log("load_test_jug_id is not defined");
			}
		}
		return false;
	}
);

$('a.adj_msg_int').live('click',
	function(){
		var num = prompt("Enter # of seconds for message interval: ");
		if(isNaN(num)){
			alert('Please enter a number. You entered ' + num);
		}else{
			if(load_test_jug_id){
				var event_channel = '_event_2';
				jug.publish(event_channel,{act: 'set_message_interval', message_interval: num, only: load_test_jug_id} );		
				console.log("set msg interval to " + num);
		  }else{
				console.log("load_test_jug_id is not defined");
			}
		}
		return false;
	}
);

setTimeout(
	function(){
		request_juggernaut_stats();
		request_load_test_stats();
	},3000
);

setInterval(
	function(){
		request_juggernaut_stats();
		request_load_test_stats();
	},10000
);

function request_load_test_stats(){
	if(load_test_jug_id){
		var event_channel = '_event_2';
		jug.publish(event_channel,
			{
				act: 'load_test_stats', 
				time_sent: new Date().getTime(), 
				only: load_test_jug_id,
				data:{
					ror_session_id: node.ror_session_id
				}
			} 
		);		
		console.log("request_load_test_stats sent to " + load_test_jug_id );
  }else{
		console.log("load_test_jug_id is not defined");
	}
}

function request_juggernaut_stats(channel){
	if( !jug ) return;
	channel = channel ? channel : '_event_2';
  if ( !channel ){
    console.log("Must provide a channel");
    return;
  } 
  //console.log("custom_publish channel: " + channel);
  var connectCallback = jug.proxy(function(){
    var message     = new Juggernaut.Message;
    message.type    = "stats";
		message.data = {
			time_sent: new Date().getTime()
		};
    message.channel = channel;
		message.data.id = jug.sessionID;
		//message.data.channel = channel;
    this.write(message);
  });

  if (jug.io.socket.connected)
    connectCallback();
  else {
    jug.on("connect", connectCallback);
  }
};
