namespace :profile do
  desc "Import ORCID identifier"
  task :import_orcid, [:file] => :environment do |task, args|
    file = args['file']
    CSV.open(file, headers: true, col_sep: "\t").each do |row|
      user = User.find_by(username: row['username'])
      next unless user
      puts row['orcid']
      user.update!(orcid: row['orcid'])
    end
  end
end
