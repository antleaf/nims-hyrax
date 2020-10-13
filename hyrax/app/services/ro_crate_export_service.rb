require 'json'
require 'tmpdir'
require 'ro_crate_ruby'

# This service generates an RO-Crate export for the specified work
# NB: this is a prototype proof-of-concept exporter and has a few rough edges!
class ROCrateExportService
  include ActionView::Helpers::NumberHelper

  def initialize(work, hostname = ENV['MDR_HOST'] || 'https://mdr.nims.go.jp')
    @work = work
    @hostname = hostname
    @work_solr = SolrDocument.new(work.to_solr)
    @presenter = show_presenter.new(
        @work_solr,
      Ability.new(nil), # always public
      Struct.new(:host).new(@hostname)
    )
  end

  def export_as_zip(zipfile)
    # First, generate the MDR metadata
    metadata = JSON.parse(@presenter.export_as_jsonld)

    # Next, create a new crate and set some basic metadata
    crate = ROCrate::Crate.new
    crate.name = @work.title.first
    crate.url = @work_solr.persistent_url(host: @hostname)
    crate.author = @work.complex_person.map{|p| p.name.first}.sort.join(', ')
    crate.license = @work.rights_statment.sort.join(', ')
    crate.publisher = @work.publisher.sort.join(', ')
    crate.add_organization('https://ror.org/026v1ze26', identifier: "https://ror.org/026v1ze26", name: "National Institute for Materials Science")
    crate.preview.template = File.read('app/views/ro_crate/preview.html.erb')

    # Loop through all associated filesets and add them to the crate
    Dir.mktmpdir do |tmpdir|
      filename = get_filename(tmpdir, 'mdr-metadata.json')
      File.open(File.join(tmpdir, filename), 'w') do |output|
        output.write(metadata.to_json)
      end
      crate.add_file(File.join(tmpdir, filename),
                     name: 'MDR Metadata (json)',
                     contentSize: number_to_human_size(File.size(File.join(tmpdir, filename))),
                     encodingFormat: 'application/ld+json' )

      # Now get a list of all the related filesets and add them to the metadata graph
      @work.file_sets.each do |file_set|
        file_set.original_file.tap do |file|
          filename = get_filename(tmpdir, file.file_name.first)

          File.open(File.join(tmpdir, filename), 'wb') do |output|
            file.stream.each { |content| output.write(content) }
          end
          crate.add_file(File.join(tmpdir, filename), contentSize: number_to_human_size(file.file_size.first), encodingFormat: file.mime_type)
        end
      end

      crate.add_file('app/assets/images/ro_crate/nims_logo.png')

      # Warning: there seems to be a bug in the RO-Crate library which does not correctly handle binary files.
      # Work around this by exporting as a Zip instead of as a folder.
      ROCrate::Writer.new(crate).write_zip(File.new(zipfile, 'w'))
    end # deletes tmpdir
    self
  end

private

  def show_presenter
    case @work.class.to_s
    when 'Dataset'
      Hyrax::DatasetPresenter
    when 'Image'
      Hyrax::ImagePresenter
    when 'Publication'
      Hyrax::PublicationPresenter
    when 'Work'
      Hyrax::WorkPresenter
    else
      Hyrax::WorkShowPresenter
    end
  end

  def get_filename(tmpdir, original_filename)
    counter = 1
    output_filename = original_filename
    extension = File.extname(output_filename)
    basename = File.basename(output_filename, extension)
    while File.exist?(File.join(tmpdir, output_filename))
      output_filename = "#{basename}-#{counter}#{extension}"
      counter += 1
    end
    output_filename
  end
end
