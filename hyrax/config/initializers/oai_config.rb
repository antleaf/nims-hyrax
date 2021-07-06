OAI_CONFIG =
    {
        provider: {
            repository_name: ENV['OAI_REPOSTIORY_NAME'],
            repository_url: ENV['OAI_REPOSITORY_URL'],     # todo: can we get this from the other places that use the base url?
            record_prefix: ENV['OAI_RECORD_PREFIX'],
            admin_email: ENV['OAI_ADMIN_EMAIL'],
            sample_id: 'x059c7329'
        },
        document: {
            limit: 25,            # number of records returned with each request, default: 15
            supported_formats: %w(oai_dc jpcoar),
        }
    }