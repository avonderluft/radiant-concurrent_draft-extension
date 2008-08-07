namespace :radiant do
  namespace :extensions do
    namespace :concurrent_draft do
      
      desc "Runs the migration of the ConcurrentDraft extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          ConcurrentDraftExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          ConcurrentDraftExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Concurrent Draft to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[ConcurrentDraftExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(ConcurrentDraftExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
