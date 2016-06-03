module Paperdragon
  # A physical file with a UID.
  #
  # Files are usually created via an Attachment instance. You can call processing
  # methods on file instances. This will save the file and return the new metadata
  # hash.
  #
  #   file = Paperdragon::File.new(uid)
  #
  #   metadata = file.reprocess! do |job|
  #     job.thumb!("16x16")
  #   end
  class File
    def initialize(uid, options={})
      @uid     = uid
      @options = options
      @data    = nil # DISCUSS: do we need that here?
    end

    attr_reader :uid, :options
    alias_method :metadata, :options

    def url(opts={})
      Dragonfly.app.remote_url_for(uid, opts)
    end

    def data
      @data ||= Dragonfly.app.fetch(uid).data
    end

    # attr_reader :meta_data

    require 'paperdragon/file/operations'
    include Process
    include Delete
    include Reprocess
    include Rename


  private
    # replaces the UID.
    def uid!(new_uid)
      @uid = new_uid
    end

    # Override if you want to include/exclude properties in this file metadata.
    def default_metadata_for(job)
      {uid: uid}
    end

    def metadata_for(job, additional={})
      default_metadata_for(job).merge(additional)
    end
  end
end