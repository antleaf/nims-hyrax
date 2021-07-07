# frozen_string_literal: true

# DownloadAllController
class DownloadAllController < Hyrax::DownloadsController
  include HyraxHelper
  include Hydra::Controller::DownloadBehavior
  include Hyrax::LocalFileDownloadsControllerBehavior

  # GET /download_all/1
  def show
    respond_to do |format|
      format.zip { send_zip }
      format.any { head :unsupported_media_type }
    end
  end

  private

  # Override from DownloadsController
  #
  # @return [String] path to zip
  def file
    @file ||= zip_file
  end

  def work
    @work ||= ActiveFedora::Base.find(params[:id])
  end

  # Override from DownloadBehavior
  def asset
    @asset ||= Hyrax::WorkPresenter.new(
      SolrDocument.new(work.to_solr),
      current_ability,
      request
    )
  end

  def file_set_ids
    work.file_sets.select do |p|
      current_ability.can?(:read, p.id)
    end.collect(&:id)
  end

  def send_zip
    if within_file_size_threshold?(file_set_ids)
      build_zip
      # Hyrax::LocalFileDownloadsControllerBehavior#send_local_content
      send_local_content
    else
      head :unsupported_media_type
    end
  end

  # Extend here to add other files to the zip
  def build_zip
    mk_zip_file_dir
    add_metadata
    add_files
    zip!
    cleanup
  end

  # Add :ttl metadata
  # Change this method to write a different metadata format
  def add_metadata
    File.write(
      File.join(zip_file_path, 'metadata.ttl'),
      asset.export_as_ttl,
      mode: 'wb'
    )
  end

  # Add all file_sets
  def add_files
    file_set_ids.each do |id|
      file_set = FileSet.find(id)
      next if file_set.blank?

      original = file_set.original_file
      next if original.blank?

      File.write(
        File.join(zip_file_path, CGI.unescape(original.file_name.first)),
        URI.parse(original.uri).open.read,
        mode: 'wb'
      )
    end
  end

  def cleanup
    FileUtils.rm_rf(zip_file_path)
  end

  def zip!
    WillowSword::ZipPackage.new(
      zip_file_path, zip_file
    ).create_zip
  end

  def zip_file_path
    File.join(
      ENV.fetch('RAILS_TMP', '/tmp'),
      file_name
    )
  end

  def zip_file
    "#{zip_file_path}.zip"
  end

  def mk_zip_file_dir
    FileUtils.mkdir_p(zip_file_path)
  end

  def file_name
    current_user.present? ? "#{asset.id}_user#{current_user.user_identifier.to_s}" : asset.id.to_s
  end

  # Override from LocalFileDownloadsControllerBehavior
  def local_file_mime_type
    'application/zip'
  end

  # Override from LocalFileDownloadsControllerBehavior
  def local_file_name
    "#{file_name}.zip"
  end

  # Override from LocalFileDownloadsControllerBehavior
  def local_derivative_download_options
    super.merge(disposition: 'attachment')
  end
end
