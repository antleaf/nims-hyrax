namespace :ngdr do
  desc 'Setup Hyrax, will read from specified file usage: ngdr:setup_hyrax["setup.json"]'
  task :"setup_hyrax", [:seedfile] => :environment do |task, args|
    seedfile = args.seedfile
    unless args.seedfile.present?
      seedfile = Rails.root.join("seed","setup.json")
    end

    if (File.exists?(seedfile))
      puts("Running hyrax setup from seedfile: #{seedfile}")
    else
      abort("ERROR: missing seedfile for hyrax setup: #{seedfile}")
    end

    seed = JSON.parse(File.read(seedfile))

    ##############################################
    # make the requested users
    ######

    depositor = false
    admin = Role.where(name: "admin").first_or_create!
    seed["users"].each do |user|
      newuser = User.find_by(username: user["username"])
      newuser = User.create!(
        username: user["username"],
        password: user["password"],
        display_name: user["name"],
        email: user["email"],
        user_identifier: user['user_identifier'],
        employee_type_code: user['employee_type_code']
      ) unless newuser

      if user["role"] == "admin"
        unless admin.users.include?(newuser)
          admin.users << newuser
          admin.save!
        end
      end

      if user.has_key?("depositor")
        depositor = newuser
      end
    end

    # finished creating users
    ##############################################


    ##############################################
    # Create default administrative set and load customized NIMS workflow
    ######
    Rake::Task['hyrax:default_collection_types:create'].invoke
    Rake::Task['ngdr:setup_workflow'].invoke

    ##############################################
    # Create languages controlled vocabulary
    ######
    Rake::Task['hyrax:controlled_vocabularies:language'].invoke if Qa::Authorities::Local.subauthority_for('languages').all.size == 0
  end
end
