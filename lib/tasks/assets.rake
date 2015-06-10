namespace :assets do
  desc 'Copies compiled favicon.ico asset into public directory'
  task :copy_favicon do
    assets_path = File.join(Rails.root, 'public', 'assets', 'favicon.ico')
    public_path = File.join(Rails.root, 'public', 'favicon.ico')
    FileUtils.cp(assets_path, public_path)
  end
end

Rake::Task['assets:precompile'].enhance do
  Rake::Task['assets:copy_favicon'].invoke
end
