# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "radiant-concurrent_draft-extension"
  s.version = "1.0.11"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andrew vonderLuft", "Sean Cribbs"]
  s.date = "2014-04-07"
  s.description = "Enables draft versions of pages, snippets and layouts, which can be scheduled for promotion."
  s.email = "avonderluft@avlux.net"
  s.extra_rdoc_files = [
    "README.textile"
  ]
  s.files = [
    "HELP.rdoc",
    "README.textile",
    "Rakefile",
    "VERSION",
    "app/views/admin/_draft_controls.html.haml",
    "app/views/admin/_edit_buttons.html.haml",
    "app/views/admin/layouts/_edit_content.html.haml",
    "app/views/admin/page_parts/_page_part.html.haml",
    "app/views/admin/pages/_edit_layout_and_type.html.haml",
    "app/views/admin/pages/_published_meta.html.haml",
    "app/views/admin/snippets/_edit_content.html.haml",
    "app/views/admin/users/_edit_roles.html.haml",
    "concurrent_draft_extension.rb",
    "config/initializers/radiant_config.rb",
    "config/locales/en.yml",
    "config/routes.rb",
    "db/migrate/001_update_schemata.rb",
    "db/migrate/002_create_draft_page_elements.rb",
    "db/migrate/003_add_publisher_role.rb",
    "lib/concurrent_draft/admin_controller_extensions.rb",
    "lib/concurrent_draft/helper_extensions.rb",
    "lib/concurrent_draft/model_extensions.rb",
    "lib/concurrent_draft/page_extensions.rb",
    "lib/concurrent_draft/site_controller_extensions.rb",
    "lib/concurrent_draft/tags.rb",
    "lib/tasks/concurrent_draft_extension_tasks.rake",
    "public/images/admin/cancel.png",
    "public/images/admin/clock.png",
    "public/images/admin/page_delete.png",
    "public/images/admin/page_edit.png",
    "public/images/admin/page_refresh.png",
    "public/images/admin/tick.png",
    "public/javascripts/admin/concurrent_draft.js",
    "public/stylesheets/admin/concurrent_draft.css",
    "radiant-concurrent_draft-extension.gemspec",
    "spec/controllers/admin_controller_extensions_spec.rb",
    "spec/controllers/site_controller_extensions_spec.rb",
    "spec/matchers/concurrent_draft_matcher.rb",
    "spec/models/model_extensions_spec.rb",
    "spec/models/page_extensions_spec.rb",
    "spec/models/tags_spec.rb",
    "spec/spec.opts",
    "spec/spec_helper.rb",
    "vendor/plugins/12_hour_time/CHANGELOG",
    "vendor/plugins/12_hour_time/README",
    "vendor/plugins/12_hour_time/Rakefile",
    "vendor/plugins/12_hour_time/init.rb",
    "vendor/plugins/12_hour_time/lib/12_hour_time.rb",
    "vendor/plugins/12_hour_time/test/12_hour_time_test.rb",
    "vendor/plugins/12_hour_time/test/test_helper.rb"
  ]
  s.homepage = "https://github.com/avonderluft/radiant-concurrent_draft-extension"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "Concurrent Draft Extension for Radiant CMS"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<radiant>, [">= 1.0.0.rc2"])
    else
      s.add_dependency(%q<radiant>, [">= 1.0.0.rc2"])
    end
  else
    s.add_dependency(%q<radiant>, [">= 1.0.0.rc2"])
  end
end

