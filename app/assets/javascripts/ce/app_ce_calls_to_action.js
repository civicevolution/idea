function call_to_action_completed(task){
	//console.log("call_to_action_completed task: " + task);
	task = $('div.cta_block.corner[id="' + task + '"]');
	if(!task.hasClass('completed')){
		task.addClass('completed')
		task.find('h1').html( task.find('h1').html() + '.' );
	}
	$('div.cta_block.hide').each(
		function(){
			if($('div.cta_block:visible').not( $('div.cta_block.completed:visible') ).size()<3){
				var cta = $(this);
				var task_details = cta_tasks[ cta.attr('id') ];
				var show_task = true;
				if(typeof task_details.view_conditions != 'undefined'){
					for(var i=0, cond; (cond=task_details.view_conditions[i]);i++){
						//console.log("test view_condition " + cond + ": " + eval(cond) );
						if(!eval( cond )){
							show_task = false;
							break;
						}
					}
				}
				if(show_task){
					cta.removeClass('hide');
				}
			}
		}
	);
}

function init_tasks(){
	if(typeof template_functions == 'undefined'){
		setTimeout(init_tasks, 300);
		return;
	}
	$('div.right_master div.calls-to-action div.cta_block').remove();
	var num_cta_visible = member.signed_in ? 3 : 4;
	var ctr = 1;
	for(task in cta_tasks){
		//console.log("task: " + task);
		var task_details = cta_tasks[task];
		// all the include_conditions must be true
		var add_task = true;
		for(var i=0, cond; (cond=task_details.include_conditions[i]);i++){
			//console.log("test include_condition " + cond + ": " + eval(cond) );
			if(!eval( cond )){
				add_task = false;
				break;
			}
		}
		if(add_task){
			//console.log("add task " + task);
			var cta = template_functions['call-to-action']({id: task, ctr: ctr, title: task_details.title, link: task_details.link || ''});
			cta = $(cta).appendTo('div.calls-to-action');
			if(ctr > num_cta_visible){
				cta.addClass('hide');
			}
			++ctr;
		}else{
			//console.log("Do not add task " + task);
		}
	}
	if(!member.signed_in){
		$('div.cta_block[id="view our plan"]').show();
	}
	
	
}

$('body').on('click','div.calls-to-action p.link', 
	function(event){
		var task_id = $(this).closest('div.cta_block').attr('id');
		//console.log("clicked on task: " + task_id);
		var task_details = cta_tasks[ task_id ];
		if(task_details.onclick){
			//console.log("task_details.onclick: " + task_details.onclick);
			eval(task_details.onclick);
		}
	}
);

$('body').on('mouseover mouseout','div.calls-to-action h3', 
	function(event){
		var cta = $(this).closest('div.cta_block');
		var task_id = cta.attr('id');
		if(event.type == 'mouseover'){
			//console.log("Show help for task: " + task_id);
			var help = templates['idea_cta_help'].find('div[id="' + task_id + '"]');
			var popup = $('<div class="help-popup"><?div>').append(help.clone());
			$('body').append(popup);
			var offset = cta.offset();
			var left = offset.left + cta.width() - popup.width()- 30;
			var top = offset.top + cta.height() + 4;
			popup.css( {top: top, left: left });			
		}else{
			//console.log("Close help for task: " + task_id);
			$('div.help-popup').remove();
		}
	}
);

$(function(){
	setTimeout(init_tasks, 200);
});

var cta_tasks = {

	'sign in' : 
		{
			title: 'Sign-in / Sign-up',
			include_conditions: ["!member.signed_in"]
		},


	'read our vision' : 
		{
			title: 'Read our Vision',
			include_conditions: ["$('div.summary_block h4.rating').hasClass('please-rate')","!participant_stats.endorse", "!member.active_participant"]
		},

	'rate our vision' :
		{
			title: 'Rate our Vision',
			include_conditions: ["$('div.summary_block h4.rating').hasClass('please-rate')"]
		},

	'endorse our vision' :
		{
			title: 'Endorse our Vision',
			link: 'Not now',
			onclick: "call_to_action_completed('endorse our vision'); $('div.cta_block[id=\"endorse our vision\"]').addClass('incomplete');",
			include_conditions: ['!participant_stats.endorse']
		},

	'view our plan' :
		{
			title: 'View our plan',
			link: 'Click here to view',
			onclick: "$('div.proposal').show(350, function(){$('html,body').animate( {scrollTop: $('div.proposal').offset().top}, 3500); call_to_action_completed('view our plan'); });",
			include_conditions: ['!member.active_participant']
		},
	
	'rate answers' : 
		{
			title: 'Rate the answers',
			include_conditions: ["$('div.answer_status div.unrated').size()>0"],
			view_conditions: ["$('div.proposal').is(':visible')"]
		},

	'discuss answers' : 
		{
			title: 'Discuss the answers',
			include_conditions: ["$('div.answer_status div.unrated').size()==0","$('ul.themes div.answer').size()>0"],
			view_conditions: ["$('div.proposal').is(':visible')"]
		},

	'rate new ideas' :
		{
			title: 'Rate new ideas',
			include_conditions: ["$('a.view_unrated_ideas:visible').size()>0"],
			view_conditions: ["$('div.proposal').is(':visible')"]
			//include_conditions: ["stat_data.idea_counts.total_ideas_unrated.length>0"]
		},
		
	'create answers' :
		{
			title: 'Create answers',
			include_conditions: ['project_coordinator','stat_data.idea_counts.total_themes_all<4'],
			view_conditions: ["$('div.proposal').is(':visible')"]
		},

	'share your ideas' :
		{
			title: 'Share your ideas',
			include_conditions: [],
			view_conditions: ["$('div.proposal').is(':visible')"]
		},
	
	'organize ideas' : 
		{
			title: 'Organize ideas',
			include_conditions: ['project_coordinator','stat_data.idea_counts.total_ideas_all>0'],
			view_conditions: ["$('div.proposal').is(':visible')"]
		},

	'Review post-its' :
		{
			title: 'Review post-its wall',
			include_conditions: ['!project_coordinator',"$('ul.themes div.answer').size()>0"],
			view_conditions: ["$('div.proposal').is(':visible')"]
		}
		
};