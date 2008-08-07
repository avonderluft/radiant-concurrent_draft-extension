class UpdateSchemata < ActiveRecord::Migration
  def self.up
    add_column :pages, :draft_promotion_scheduled_at, :datetime
    add_column :pages, :draft_promoted_at, :datetime
    add_column :page_parts, :draft_content, :text
    add_column :snippets, :draft_promotion_scheduled_at, :datetime
    add_column :snippets, :draft_promoted_at, :datetime
    add_column :snippets, :draft_content, :text
    add_column :layouts, :draft_promotion_scheduled_at, :datetime
    add_column :layouts, :draft_promoted_at, :datetime
    add_column :layouts, :draft_content, :text
    Page.reset_column_information
    PagePart.reset_column_information
    Snippet.reset_column_information
    Layout.reset_column_information
  end

  def self.down
    remove_column :pages, :draft_promotion_scheduled_at
    remove_column :pages, :draft_promoted_at
    remove_column :page_parts, :draft_content
    remove_column :snippets, :draft_content
    remove_column :layouts, :draft_content
  end
end
