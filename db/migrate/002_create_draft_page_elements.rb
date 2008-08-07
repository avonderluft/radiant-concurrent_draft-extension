class CreateDraftPageElements < ActiveRecord::Migration
  def self.up
    PagePart.update_all("draft_content = content")
    Snippet.update_all("draft_content = content")
    Layout.update_all("draft_content = content")
  end

  def self.down
  end
end
