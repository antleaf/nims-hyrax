Blacklight.onLoad(function() {
	$('.corresponding_author').click(function(e) {
		// Set the hidden input field with the correct value
	    if (this.checked) {
	    	$(this.element).parent('div').find('input[type=hidden]').first().val('1');
	    } else {
	        $(this.element).parent('div').find('input[type=hidden]').first().val('0');
	    }
	});
});
