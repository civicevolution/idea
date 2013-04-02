post_theme_changes.update_fn = function(){
	//console.log("post_theme_changes.update_fn");
	// clear any examples that ended up in the unthemed or parked lists
	$('div#unthemed_ideas div.post-it.example, div#parked_ideas div.post-it.example').each(
		function(){
			$(this).removeClass('example');
		}
	);
	if( page_data.type == 'macro theming' ){
		//console.log("UPDATE stats for macro theming");
		$('div.table').each(
	    function(){
	      var stat = $(this);
	      var themer_id = stat.attr('themer_id');
	      stat.find('span.unthemed_uT_count').html( ':' + $('div#unthemed_ideas div.post-it[table_id="' + themer_id + '"]').size() );
	      stat.find('span.themed_uT_count').html( '-' + $('div.theme_col.themes div.post-it[table_id="' + themer_id + '"]').size() );
	    }
	  );
	}else{
	  $('div.table').each(
	    function(){
	      var stat = $(this);
	      var table_id = stat.attr('table_id');
	      stat.find('span.unthemed_tp_count').html( ':' + $('div#unthemed_ideas div.post-it[table_id="' + table_id + '"]').size() );
	      stat.find('span.themed_tp_count').html( '-' + $('div.theme_col.themes div.post-it[table_id="' + table_id + '"]').size() );
	      stat.find('span.example_tp_count').html( '-' + $('div.theme_col div.post-it.example[table_id="' + table_id + '"]').size() );
	    }
	  );
	}
}
post_theme_changes.update_fn();

setTimeout(expire_old_status,10000);
function expire_old_status(){
  //console.log("expire_old_status");
  $('div.table').each(
    function(){
      var stat = $(this);
      var last_update_ctr = stat.attr('last_update_ctr');
      if(last_update_ctr++ < 3){
        stat.attr('last_update_ctr', last_update_ctr);
      }else{
        stat.addClass('warn');
      }
    }
  );
  setTimeout(expire_old_status,10000);
}

function update_status_report(message){
  if(message.role == 'scribe' &&
    message.page_type.session_id == page_data.source_session_id &&
    message.page_type.type == 'enter talking points'
  ){
    try{
      var table_id = message.name.match(/\d+/)[0];
      var stat = $('div.table[table_id="' + table_id + '"]');
      stat.attr('jug_id', message.jug_id);
      $('div.chat[table_id="' + table_id + '"] input#jug_id').val( message.jug_id );
      stat.removeClass('warn');
      stat.attr('last_update_ctr',0);
    }catch(e){}
  }
}

$( "div.table" ).live('mouseenter mouseleave', function(event) {
  var div = $(this);
  if (event.type == 'mouseenter') {
    var offset = div.offset();
    div.find('div.table_menu').css({display: 'block', top: offset.top + div.outerHeight(), left: offset.left });
  } else {
    
    div.find('div.table_menu').css({display: 'none'})
  }
});

$('div.show_chat').live('click',
  function(){
    var table_div = $(this).closest('div.table');
    if(table_div.hasClass('warn')) return;
    table_div.removeClass('new_message');
    table_div.find('div.table_menu').hide();
    var table_id = table_div.attr('table_id');
    var chat = $('div.chat[table_id="' + table_id +'"]');
    if(chat.size()==0){
      chat = add_chat_form(table_id, table_div.attr('jug_id') );
    }
    $('div.chat').not('div#coord_chat').hide();
    var offset = table_div.offset();
    chat.css({display: 'block', top: offset.top + table_div.outerHeight(), left: offset.left });
    chat.find('input[type="text"]').focus();
  }
);
$('div.chat p.hdr a').live('click',
  function(){
    $(this).closest('div.chat').hide();
    return false;
  }
);
function add_chat_form(table_id, jug_id){
  console.log("add_chat_form table_id: " + table_id + ', jug_id: ' + jug_id);
  var chat = $('div.chat.orig').clone();
  chat.removeClass('orig').attr('table_id',table_id);
  // set the recip_jug_id when I open the table chat
  chat.find('input#jug_id').val( jug_id );
  chat.find('span.table_id').html(table_id);
  $('body').append(chat);
  return chat;
}

function update_chat(data){
  if(data.id == themer_parent_jug_id){
     update_coordinator_chat(data);
     return;
  }
  var table_div = $('div.table[jug_id="' + data.id + '"]');
  var table_id = table_div.attr('table_id');
  var chat = $('div.chat input#jug_id[value="' + data.id + '"]').closest('div.chat');
  if(chat.size() == 0){
    // create chat if it doesn't exist
    var chat = add_chat_form(table_id, data.id);
  }
  var chat_log = chat.find('div.chat_log');
  // add message to chat
  if(chat_log.find('p:last').attr('node_id') == data.node_id){
    chat_log.append('<p node_id="' + data.node_id + '">' + data.msg + '</p>').scrollTop(99999999);
  }else{
    chat_log.append('<p node_id="' + data.node_id + '">' + data.name + ': ' + data.msg + '</p>').scrollTop(99999999);
  }
  // add message indicator
  table_div.addClass('new_message');
  // show message for 5 secs, unless this chat form is already visible
  if( !chat.is(':visible') ){
    var msg_alert = $('<div class="chat_alert">Msg from T' + table_id + ': ' + data.msg + '</div>');
    $('body').append(msg_alert);
    var offset = table_div.offset();
    msg_alert.css({top: offset.top + table_div.outerHeight(), left: offset.left, 'z-index': 1000 });
    msg_alert.fadeTo(3000,1,function(){$(this).fadeTo(2000,0,function(){$(this).remove();})});
  }
}
$('a.canned_messages').live('click',
  function(){
    console.log("canned_messages");
    var chat = $(this).closest('div.chat');
    var canned_messages = chat.find('div.canned_messages');
    canned_messages.toggle();
    return false;
  }
);
$('div.canned_messages a').live('click',
  function(){
    console.log("Use this canned_message");
    $(this).closest('div.chat').find('input#msg').val( $(this).html() );
    $(this).closest('div.chat').find('div.canned_messages').hide();
    return false;
  }
);


$('div.show_tp').live('click',
  function(){
    console.log("Show all the tp for this table");
  	$.getScript('/live/' + page_data.session_id + '/group_tp/' + $(this).closest('div.table').attr('table_id') )
    $(this).closest('div.table_menu').hide();
  }
);


function update_coordinator_chat(data){
  var chat = $('div#coord_chat');
  var link = $('a.coord_chat');
  var offset = link.offset();
  chat.css({display: 'block', top: offset.top + link.outerHeight(), left: offset.left })
  
  var chat_log = chat.find('div.chat_log');
  if(chat_log.find('p:last').attr('node_id') == data.node_id){
    chat_log.append('<p node_id="' + data.node_id + '">' + data.msg + '</p>').scrollTop(99999999);
  }else{
    chat_log.append('<p node_id="' + data.node_id + '">' + data.name + ': ' + data.msg + '</p>').scrollTop(99999999);
  }
}
$('div.chat p.hdr a').live('click',
  function(){
    $(this).closest('div.chat').hide();
    return false;
  }
);

//$(function(){
//  $('div.join_com').prepend(' /');
//  $('div.join_com').prepend( $('<a href="#" class="coord_chat">Chat with coordinator</a>') );
//  $('div.join_com').prepend(' / ');
//  $('div.join_com').prepend( $('<a href="#" class="fix_page">Fix page</a>') );
//});
$('a.fix_page').live('click',function(){live_resize(); return false;});
$('a.coord_chat').live('click',
  function(){
    var chat = $('div#coord_chat');
    var link = $(this);
    var offset = link.offset();
    chat.css({display: 'block', top: offset.top + link.outerHeight(), left: offset.left });
    chat.find('input[type="text"]').focus();
    return false;
  }
);