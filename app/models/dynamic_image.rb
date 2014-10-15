class DynamicImage < ActiveRecord::Base
  validates_presence_of :book_id
  validates :image_location,  :presence => true, :length => { :maximum => 255 }

  PAPERCLIP_STYLES = { :medium => "400x300>", :thumb => "160x120>" }
  if ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY'] && ENV['POET_ASSET_BUCKET']
    has_attached_file :physical_file, {:styles => PAPERCLIP_STYLES,  :path => :path_by_book}.merge(PAPERCLIP_S3_STORAGE_OPTIONS)
  else
    has_attached_file :physical_file, :styles => PAPERCLIP_STYLES, :path => :path_by_book
  end

  belongs_to :book
  has_one :dynamic_description
  has_one :image_category

  def as_json(options = {})
    json = super(options)
    json['thumb_source'] = thumb_source(options[:host])
    json['image_source'] = image_source(options[:host])
    json['author'] = dynamic_description.submitter_name() if dynamic_description
    json
  end

  def image_source(host)
    return "#{host}/#{book.uid}/original/#{image_location}"
  end

  def thumb_source(host)
    if thumbnailable?
      "#{host}/#{book.uid}/thumb/#{image_location}"
    else
      image_source(host)
    end
  end

  def medium_source(host)
    if thumbnailable?
      "#{host}/#{book.uid}/medium/#{image_location}"
    else
      image_source(host)
    end
  end

  def thumbnailable?
    return false unless physical_file.content_type
    ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png', 'image/jpg'].join('').include?(physical_file.content_type)
  end

  private

  def path_by_book
    path = "#{book.uid}/:style/#{image_location}"
    if ENV['POET_LOCAL_STORAGE_DIR']
      path = File.join(ENV['POET_LOCAL_STORAGE_DIR'], path)
    end
    path
  end
end
