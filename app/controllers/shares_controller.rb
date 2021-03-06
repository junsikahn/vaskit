class SharesController < ApplicationController
  # GET /shares/new.json
  def new
    if params[:share_type] == 'ask'
      share_data = Ask.find(params[:target_id])
                      .as_json(include: [:user, :left_ask_deal, :right_ask_deal])
    elsif params[:share_type] == 'collection'
      share_data = Collection.find(params[:target_id])
    elsif params[:share_type] == 'video'
      share_data = Video.find(params[:target_id])
    end
    render json: { share_data: share_data }
  end

  # POST /shares.json
  def create
    user_id = current_user ? current_user.id : nil
    preview_image = PreviewImage.create(user_id: user_id, image: params[:File])
    image_url = preview_image.image.url(:crop) unless preview_image.image.blank?
    render json: { image_url: image_url }
  end
end
