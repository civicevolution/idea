
  console.log("load live_vote.js");
	
	//$(window).scrollTop(0)

	$('div#proposal_vote :text').die('keyup').live('keyup',
		function(){
			var val = $(this).val();
			// check the total
			var sum = show_vote_sum();
			console.log("the sum is " + sum);
			if(sum>100){
				var reset_val = val - (sum - 100);
				reset_val = reset_val >= 0 ? reset_val : 0;
				reset_val = reset_val <= 30 ? reset_val : 30;
				$(this).val( reset_val );
				show_vote_sum();
				var warn = $('<tr><td colspan="2"><p class="vote_warn">You cannot enter more than $100</p></td></tr>').insertAfter( $(this).closest('tr'));
				warn.fadeTo(3000,0,
					function(){
						$(this).remove();
					}
				);
				
			}
			// check the value
			if(val>30){
				if(sum<=100){
					$(this).val(30);
				}
				var warn = $('<tr><td colspan="2"><p class="vote_warn">You cannot give this proposal more than $30</p></td></tr>').insertAfter( $(this).closest('tr'));
				warn.fadeTo(3000,0,
					function(){
						$(this).remove();
					}
				);
				
				sum = show_vote_sum();
			}			
			return false;
		}
	);
	function show_vote_sum(){
		var sum = 0;
		$('div#proposal_vote :text').each(
			function(){
				sum += Number($(this).val());
			}
		);
		$('div#proposal_vote span.alloc').html(sum);
		$('div#proposal_vote span.avl').html(100-sum);		
		return sum;	
	}
	
	$('div#proposal_vote a.cancel').html('Close').die('click').live('click',
		function(){
			$(this).closest('div.ui-dialog').dialog('destroy').remove();
			return false;
		}
	);
