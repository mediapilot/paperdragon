require 'test_helper'

require 'paperdragon/paperclip'

class PaperclipUidTest < MiniTest::Spec
  Uid = Paperdragon::Paperclip::Uid

  let (:options) { {:class_name => :avatars, :attachment => :image, :id => 1234,
    :style => :original, :updated_at => Time.parse("20-06-2014 9:40:59 +1000").to_i,
    :file_name => "kristylee.jpg", :hash_secret => "secret"} }

  it { Uid.from(options).
    must_equal "system/avatars/image/000/001/234/9bf15e5874b3234c133f7500e6d615747f709e64/original/kristylee.jpg" }


  class UidWithFingerprint < Paperdragon::Paperclip::Uid
    def call
      "#{root}/#{class_name}/#{attachment}/#{id_partition}/#{hash}/#{style}/#{fingerprint}-#{file_name}"
    end
  end

  it { UidWithFingerprint.from(options.merge(:fingerprint => 8675309)).
    must_equal "system/avatars/image/000/001/234/9bf15e5874b3234c133f7500e6d615747f709e64/original/8675309-kristylee.jpg" }
end


class PaperclipModelTest < MiniTest::Spec
  class Avatar
    class Photo < Paperdragon::File
    end

    class Attachment < Paperdragon::Attachment
      self.file_class = Photo

      def exists?
        "Of course!"
      end
    end

    class PictureAttachment < Paperdragon::Attachment
      self.file_class = Photo

      def exists?
        "Of course it's a Picture!"
      end
    end

    include Paperdragon::Paperclip::Model
    processable :image, Attachment
    processable :picture, PictureAttachment


    def image_meta_data
      {:thumb => {:uid => "Avatar-thumb"}}
    end

    def picture_meta_data
      {:thumb => {:uid => "Picture-thumb"}}
    end
  end

  describe "image" do
    # old paperclip style
    it { Avatar.new.image.url(:thumb).must_equal "/paperdragon/Avatar-thumb" }

    # paperdragon style
    it { Avatar.new.image[:thumb].url.must_equal "/paperdragon/Avatar-thumb" }

    # delegates all unknown methods back to Attachment.
    it { Avatar.new.image.exists?.must_equal "Of course!" }
  end

  describe "picture" do
    # old paperclip style
    it { Avatar.new.picture.url(:thumb).must_equal "/paperdragon/Picture-thumb" }

    # paperdragon style
    it { Avatar.new.picture[:thumb].url.must_equal "/paperdragon/Picture-thumb" }

    # delegates all unknown methods back to Attachment.
    it { Avatar.new.picture.exists?.must_equal "Of course it's a Picture!" }
  end
end
