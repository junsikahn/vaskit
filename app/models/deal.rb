class Deal < ActiveRecord::Base
  NAVER_RESULT_PER = 10

  has_many :ask_deals

  has_attached_file :image,
                    url: '/assets/deals/:id/:style/:basename.:extension',
                    path: ':rails_root/public/assets/deals/:id/:style/:basename.:extension',
                    default_url: '/images/custom/card_image_preview.png'
  validates_attachment_size :image, less_than: 20.megabytes
  validates_attachment_content_type :image, content_type: ['image/jpeg', 'image/pjpeg', 'image/pjpeg', 'image/png', 'image/jpg', 'image/gif', 'application/octet-stream']

  before_post_process :rename_file

  def rename_file
    return if image.blank?
    extension = image_file_name.split('.').last
    return unless %w[jpg jpeg gif png].include?(extension)
    charset = %w[2 3 4 6 7 9 a b c d e f g h i j k l m n o p q r s t v w x y z]
    self.image_file_name = (0...6).map { charset.to_a[rand(charset.size)] }.join + ".#{extension}"
  end
end
