jQuery.fn.hasVal = function() { 
  return this !== null && this.val().length > 0; 
}

export class RequiredFields {
  // Monitors the form and runs the callback if any of the required fields change
  constructor(form, callback) {
    this.form = form
    this.callback = callback
    this.reload()
  }

  get areComplete() {
    var missing = this.requiredFields.filter((n, elem) => { return this.isRequiredButBlank(elem) } )
    return missing.length === 0
	}
	
  // helper to clear the 'required' styling
  notRequired(elem, label) {
    $(label).removeClass('required')
  	$(label).find('span').remove()
		
  	$(elem).removeClass('required');
	  $(elem).attr('required', null);
	  $(elem).removeAttr('style');
  }

  required(elem, label) {
    $(label).addClass('required control-label')
		$(label).append('<span class="label label-info required-tag">required</span>')
		$(elem).addClass('required');
		$(elem).attr('required', 'required');
		$(elem).css('box-shadow','0px 0px 0px 2px red');
  }

	isRequiredButBlank(elem) {
    // if the value is filled in, do not check further
    if($(elem).hasVal()) return false

    var requiredButBlank = false
    if($(elem).data('required')){
      var requirements = $(elem).data('required').split(';')

      // Special "any" case
      if(requirements.includes('any')){
        $(elem).parents('.form-group').find(':input').not('[type=hidden], [data-skip=true]').each(function(i) {
          if($(this).hasVal()) return (requiredButBlank = true)
        })
      } else {
        // Go through each requirement
        $.each(requirements, function(i, e) {
          if($(`input[data-name=${e}]`).hasVal()) return (requiredButBlank = true)
        })
      }

      // TODO this label replace is not right, but ids with [] are not allowed in htlm
      // and need to be fixed in the nested inputs. Jquery throws an exeption if we try
      // to match on for block with square brackets
      var elem_id = elem.id.replace(/\[|\]/g, '_')
      var label = $(`label[for=${elem_id.replace(/__/g, '_')}]`)
      // var label = $(`label[for=${elem.id.replace(/\[|\]/g, '_')}]`)

      // only run css updates if they are needed, as they are expensive
      // this first one never gets called
      if(!requiredButBlank && label.hasClass('required')) {
        this.notRequired(elem, label)
      } else if( requiredButBlank && !label.hasClass('required')) {
        this.required(elem, label)
      }
      return requiredButBlank
    } else {
      return true
    }
	}

  // Reassign requiredFields because fields may have been added or removed.
  reload() {
		// ":input" matches all input, select or textarea fields.
		this.requiredFields = this.form.find(':input[required], :input.required-if')
		this.requiredFields.change(this.callback)
  }
}
