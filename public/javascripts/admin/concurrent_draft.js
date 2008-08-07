var Draft = {};

Draft.ControlBox = Behavior.create({
  initialize: function(){
    document.observe('click', Element.removeClassName.curry(this.element, 'active'));
  },
  onclick: function(e){
    e.stop();
    this.element.addClassName('active');
  }
});

Draft.RevertLink = Behavior.create({
  initialize: function(){
    this.popup = $('revert-draft-popup'); 
  },
  onclick: function(e){
    e.stop();
    this.element.up('.active').removeClassName('active');
    $$('input[name*="[content]"]').each(this.copyData);
    center(this.popup);
    this.popup.show();
  },
  copyData: function(input){
    var draft_id = input['name'].gsub(/content/, 'draft_content').gsub(/[\[\]]+/, '_').sub(/\_*$/, '');
    if($(draft_id))
      $(draft_id).value = input.value;
  }
});

Draft.ScheduleLink = Behavior.create({
  onclick: function(e){
    e.stop();
    this.element.up('.active').removeClassName('.active');
    var element = $(this.element.href.split('#')[1]);
    center(element);
    element.show();
    element.down('form').focus();
  }
});


Event.addBehavior({
  '#draft-controls': Draft.ControlBox,
  '#draft-controls li.revert a': Draft.RevertLink,
  '#draft-controls li.schedule_draft a': Draft.ScheduleLink
});