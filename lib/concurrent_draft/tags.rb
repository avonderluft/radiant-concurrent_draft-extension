module ConcurrentDraft::Tags
  include Radiant::Taggable

  def self.included(base)
    base.class_eval do
      alias_method "tag:old_content", "tag:content"
      alias_method "tag:content", "tag:concurrent_draft_content"
      if defined?(SnippetsExtension)
        alias_method "tag:old_snippet", "tag:snippet"
        alias_method "tag:snippet", "tag:concurrent_draft_snippet"
      end
    end
  end

  tag 'concurrent_draft_content' do |tag|
    page = tag.locals.page
    part_name = tag_part_name(tag)
    boolean_attr = proc do |attribute_name, default|
      attribute = (tag.attr[attribute_name] || default).to_s
      raise TagError.new(%{`#{attribute_name}' attribute of `content' tag must be set to either "true" or "false"}) unless attribute =~ /true|false/i
      (attribute.downcase == 'true') ? true : false
    end
    inherit = boolean_attr['inherit', false]
    part_page = page
    if inherit
      while (part_page.part(part_name).nil? and (not part_page.parent.nil?)) do
        part_page = part_page.parent
      end
    end
    contextual = boolean_attr['contextual', true]
    part = part_page.part(part_name)
    ###      CONCURRENT DRAFTS CHANGE      ###
    # Show the draft content on the dev site #
    part.content = part.draft_content if part && dev?(tag.globals.page.request)
    ###    END CONCURRENT DRAFTS CHANGE    ###
    tag.locals.page = part_page unless contextual
    tag.globals.page.render_snippet(part) unless part.nil?
  end

  if defined?(SnippetsExtension)
    tag 'concurrent_draft_snippet' do |tag|
      if name = tag.attr['name']
        if snippet = Snippet.find_by_name(name.strip)
          tag.locals.yield = tag.expand if tag.double?
          ###      CONCURRENT DRAFTS CHANGE      ###
          # Show the draft content on the dev site #
          # Promote the snippet if it needs to be  #
          snippet.promote_draft! if snippet.draft_should_be_promoted?
          snippet.content = snippet.draft_content if dev?(tag.globals.page.request)
          ###    END CONCURRENT DRAFTS CHANGE    ###
          tag.globals.page.render_snippet(snippet)
        else
          raise StandardTags::TagError.new("snippet not found: #{name}")
        end
      else
        raise StandardTags::TagError.new("`snippet' tag must contain `name' attribute")
      end
    end
  end
  
end