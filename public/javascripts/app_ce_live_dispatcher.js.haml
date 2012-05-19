setTimeout(expire_old_status,10000);
function expire_old_status(){
  //console.log("expire_old_status");
  var trs = $('tr.status');
  if( trs.size() > 0 ){
    trs.each(
      function(){
        var tr = $(this);
        var last_update_ctr = tr.attr('last_update_ctr');
        if(last_update_ctr++ < 3){
          tr.attr('last_update_ctr', last_update_ctr);
        }else{
          tr.find('td.page').addClass('warn').html('Disconnected');
          tr.find('td.activity').html( '' );
        }
      }
    );
  }
  setTimeout(expire_old_status,10000);
}

function update_status_report(message){
  var tr = $('tr[jug_id="' + message.jug_id + '"]');
  var page_descr  = message.page_type.type;
  if(message.page_type.session_title){
    page_descr += ':' + message.page_type.session_title.substring(0,30)
  }
  tr.find('td.page').removeClass('warn').html( page_descr );
  tr.find('td.activity').html( message.activity );
  tr.attr('last_update_ctr',0);
}
