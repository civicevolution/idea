var json_templates = {}, directives, template_data, jsonFn;
var json_test_data;
function create_templates(data){
	//console.log("create_templates")
	template_data = $(data.replace(/src=['"]['"]/g,''))
	// break up the template into sub templates
	//var tmps = json_templates['full'];
	json_templates['full'] = template_data;
	json_templates['answer'] = $('div.answer_section', template_data);
	json_templates['bs_idea'] = $('div.bs_idea', template_data);
	json_templates['comment'] = $('div.Comment', template_data);
	json_templates['resource'] = $('div.resource', template_data);//.remove();
	json_templates['chat_message'] = $('tr.Chat', template_data);
	json_templates['add_comment_form'] = $('form.add_comment_form', template_data);	
	json_templates['add_answer_form'] = $('form.add_answer_form:last', template_data);
	json_templates['add_bs_idea_form'] = $('form.add_bs_idea_form', template_data);			
	json_templates['endorsement'] = $('div#endorsements tr:last', template_data);			
	
	//console.log("set the template directives")
	directives = {
		answer : {
			'@uid' : 'uid',
			'div.answer @id+' : 'data.answer.id',
			'div.answer' : function(arg){return simple_format(unescape(arg.context.data.answer.text))},
			'a.history @href+' : '/#{data.answer.id}',
			'a.report @href+' : '/#{item_id}',
			"input[type='radio'] @name+" : 'data.answer.id',
			'div.ans_comment_links span' : function(arg){return arg.context.data.answer.ver == 0 ? 'Original version' : 'Version ' + arg.context.data.answer.ver },
			'div.cnt' : function(arg){return arg.context.my_vote == null || arg.context.my_vote == 0 ? 'Please rate' : '(' + arg.context.count + ( arg.context.count == 1 ? ' vote' : ' votes') + ')' },
			'div.bs_rating_red_bg @style' : function(arg){return 'width: ' + (arg.context.average * 17) + 'px' }
		},
		bs_idea : 
		{
		  '@uid' : 'uid',
			'@id+' : 'data.bs_idea.id',
		  'div.bs_idea_inner div.text' : function(arg){return simple_format(unescape(arg.context.data.bs_idea.text))},
			'p.not_published @class+' : function(arg){return (arg.context.data.bs_idea.publish != null) ? ' hide' : '' }
		},
		comment : {
			'@id' : 'i#{item_id}',
		  '@uid' : 'uid',
		  '@item_id' : 'item_id',
		  'div.Comment_entry @id+' : 'data.comment.id',	
		  'div.Comment_entry @target_type' : 'item.item.target_type',	
		  'div.Comment_entry @target_id' : 'item.item.target_id',	
			'abbr.timeago @title' : 'data.comment.created_at',
			'div.comment_text' : function(arg){return simple_com_format(arg.context)},
			'div.resource' : function(arg){return arg.context.resource.resource.id ? jsonFn.resource(arg.context) : '' },
			'div.resource @class+' : function(arg){return arg.context.resource.resource.id ? '' : ' hide' },
			'a.edit_com @href+' : '/#{data.comment.id}',
			'a.edit_com @class+' : function(arg){return (arg.context.edit_link != 'on') ? ' hide' : '' },
			'a.reply @href+' : '/#{data.comment.id}',
			"input[name='thumbsup_id'] @value" : 'data.comment.id',
			'span.votes_up' : function(arg){return (arg.context.up>0) ? arg.context.up : '0' },
			'span.votes_down' : function(arg){return (arg.context.down>0) ? arg.context.down : '0' },
			'p.not_published @class+' : function(arg){return (arg.context.data.comment.publish != null) ? ' hide' : '' }
		},	
		resource : {
			'@class' : 'clear',
			'h3.resource_title' : function(arg){return unescape(arg.context.resource.resource.title) },
			'div.resource_description' : function(arg){return simple_format(unescape(arg.context.resource.resource.description))},
			'p.resource_link' : function(arg){return unescape(arg.context.resource_link) }
		},
		chat_message : {
			'@id' :'chat_#{chat_msg_id}',			
			'p.name' : function(arg){return unescape(arg.context.name) || arg.context.from.properties.name },
			'p.msg' : function(arg){return unescape(arg.context.text)},
			'td.pic' : '<img src="#{pic_url}" />'			
		},
		add_comment_form:{
			"input[name='par_id'] @value" : 'par_id',
			"input[name='mode'] @value" : 'mode',
			"input[name='id'] @value" : 'id',
			"input[name='resource_type'] @value" : 'resource_type',
			"input[name='comment[target_id]'] @value" : 'tgt_id',
			"input[name='comment[target_type]'] @value" : 'tgt_type'
		},
		add_answer_form:{
			"input[name='par_id'] @value" : 'par_id',
			"input[name='mode'] @value" : 'mode',
			"input[name='id'] @value" : 'id',
			"span.char_ctr" : '#{char_cnt} characters left'
		},
		add_bs_idea_form : {
			"input[name='mode'] @value" : 'mode',
			"input[name='bs_idea[question_id]'] @value" : 'q_id',
			"input[name='idea_id'] @value" : 'id'
		},
		endorsement : {
				'@id' : 'ape_code',
				'td.pic' : '<img src="#{pic_url}" />',
				'td.name' : function(arg){ return unescape(arg.context.name);},
				'td.text' : function(arg){ return simple_format(arg.context.data.endorsement.text)},
				'abbr.timeago' : function(arg){ return 'just now'},
				'abbr.timeago @title' : 'data.endorsement.updated_at',
				'td.delete @class+' : function(arg){return arg.context.show_delete == 't' ? '' : ' hide'; }
		}
		
	}	
	
	jsonFn = {
		answer: json_templates.answer.compile(directives.answer),
		bs_idea: json_templates.bs_idea.compile(directives.bs_idea),
		comment: json_templates.comment.compile(directives.comment),
		//resource: json_templates.resource.compile(directives.resource),
		//chat_message: json_templates.chat_message.compile(directives.chat_message),
		add_comment_form: json_templates.add_comment_form.compile(directives.add_comment_form),
		add_answer_form: json_templates.add_answer_form.compile(directives.add_answer_form),
		add_bs_idea_form : json_templates.add_bs_idea_form.compile(directives.add_bs_idea_form),
		endorsement : json_templates.endorsement.compile(directives.endorsement)	
	}
	return false;
}

function simple_format(s){
	var strs = unescape(s).split(/\n\n/)
	s = ''
	for(var i=0;str=strs[i];i++) s += '<p>'+str+'</p>'
	return s.replace(/\n/g,'<br/>')
}

function simple_com_format(context){
	var s = unescape(context.data.comment.text);
	var strs = s.split(/\n\n/)
	s = ''
	for(var i=0;str=strs[i];i++) s += '<p>'+str+'</p>'
	s = s.replace(/\n/g,'<br/>')
	
	var author = '<a href="/idea/author_info/' + context.ape_code + ' class="com_author">' + unescape(context.author) + '</a>'

  s = s.replace(/<p>/,'<p>' + author + ' ')
	console.log("simple_com_format s: " + s)
	return s;
	
}

