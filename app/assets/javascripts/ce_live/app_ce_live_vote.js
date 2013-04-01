
  console.log("load live_vote.js");
	
	//$(window).scrollTop(0)

	$('div#proposal_vote :text').die('keyup').live('keyup',
		function(){
			var val = $(this).val();
			if(val<0 || isNaN(val) ){
			  $(this).val(0);
			}
			// check the total
			var sum = show_vote_sum();
			//console.log("the sum is " + sum);
			if(sum>100){
				var reset_val = val - (sum - 100);
				reset_val = reset_val >= 0 ? reset_val : 0;
				reset_val = reset_val <= 40 ? reset_val : 40;
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
			if(val>40){
				if(sum<=100){
					$(this).val(40);
				}
				var warn = $('<tr><td colspan="2"><p class="vote_warn">You cannot give this proposal more than $40</p></td></tr>').insertAfter( $(this).closest('tr'));
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

	$('a.clear').die('click').live('click',
		function(){
			$('td.points input').val(0);
			$('input[id="voter_id"]').val('');
			$('span.voter_id').html('New');
			show_vote_sum();
			return false;
		}
	);
  $('td.points input').keydown(function(event){
    if(event.keyCode == 13) {
      event.preventDefault();
      // move to next input
      var inputs = $(this).closest('form').find(':input');
      var next_input = inputs.eq( inputs.index(this)+ 1 );
      next_input.focus();
      return false;
    }
  });
  $(':text').bind('focus', function(){
    var inp = $(this);
    if(inp.val() == 0)inp.val('');
  });
  $(':text').bind('blur', function(){
    var inp = $(this);
    if(inp.val() == '')inp.val(0);
  });
  
  $(':text:first').focus();