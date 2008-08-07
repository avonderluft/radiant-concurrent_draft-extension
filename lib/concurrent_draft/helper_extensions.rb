module ConcurrentDraft::HelperExtensions
  def updated_stamp(model)
    unless model.new_record?
      updated_by = (model.updated_by || model.created_by)
      login = updated_by ? updated_by.login : nil
      time = (model.updated_at || model.created_at)
      promoted_at = model.draft_promoted_at if model.respond_to?(:draft_promoted_at)
      html = %{<p style="clear: left"><small>}
      if login or time
        html << 'Last updated ' 
        html << %{by #{login} } if login
        html << %{at #{ timestamp(time) }} if time
        html << '. '
      end
      if promoted_at
        html << %{Last promoted at #{ timestamp(promoted_at) }.}
      end
      html << %{</small></p>}
      html
    else
      %{<p class="clear">&nbsp;</p>}
    end
  end
end