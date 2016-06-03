module Paperdragon
  class File
    # DISCUSS: allow the metadata passing here or not?
    module Process
      def process!(file, new_uid=nil, metadata={})
        job = Dragonfly.app.new_job(file)

        yield job if block_given?

        old_uid = uid
        uid!(new_uid) if new_uid # set new uid if this is a replace.

        upload!(job, old_uid, new_uid, metadata)
      end

    private
      # Upload file, delete old file if there is one.
      def upload!(job, old_uid, new_uid, metadata)
        job.store(path: uid, headers: { 'x-amz-acl' => 'public-read' }) #, "Content-Type" => "image/jpeg"})

        if new_uid # new uid means delete old one.
          Dragonfly.app.destroy(old_uid)
        end

        @data = nil
        metadata_for(job, metadata)
      end
    end


    module Delete
      def delete!
        Dragonfly.app.destroy(uid)
      end
    end


    module Reprocess
      def reprocess!(new_uid, original, metadata={})
        job = Dragonfly.app.new_job(original.data) # inheritance here somehow?

        yield job if block_given?

        old_uid = uid
        uid!(new_uid) # new UID is already computed and set.

        upload!(job, old_uid, new_uid, metadata)
      end
    end


    module Rename
      def rename!(fingerprint, metadata={}) # fixme: we are currently ignoring the custom metadata.
        old_uid = uid
        uid!(fingerprint)

        yield old_uid, uid

        Dragonfly.app.destroy(old_uid)

        self.metadata.merge(:uid => uid) # usually, metadata is already set to the old metadata when File was created via Attachment.
      end
    end
  end
end