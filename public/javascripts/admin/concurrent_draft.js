Event.addBehavior({'a.popup': Popup.TriggerBehavior()});

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
    $$('input[name*="[content]"]').each(this.copyData, this);
    center(this.popup);
    this.popup.show();
  },
  copyData: function(input){
    // var draft_id = input.name.gsub(/content/, 'draft_content').gsub(/[\[\]]+/, '_').sub(/\_*$/, '');
    var draft_id = input.id.gsub(/content/, 'draft_content');
    var draft = $(draft_id);
    // The following was modified to accommodate templates extension
    if (draft) {
      switch(draft.type){
        case 'checkbox':
          draft.checked = (input.value == draft.value);
          break;
        default:
          draft.value = input.value;
          break;
      }
      draft.fire('draft:reverted');
    } else {
      // for true/false radio buttons in templates extension
      var draft_true = document.getElementById(draft_id + '_true');
      var draft_false = document.getElementById(draft_id + '_false');
      if (draft_true && draft_false && draft_true.type == 'radio' && draft_false.type == 'radio') { 
        if (input.value == 'true') {
          draft_true.checked = true;
        } else if (input.value == 'false') {
          draft_false.checked = true;
        }
      }
    }
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