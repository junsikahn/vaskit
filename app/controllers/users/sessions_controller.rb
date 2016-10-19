# -*- coding: utf-8 -*-
class Users::SessionsController < Devise::SessionsController
  skip_before_filter :auth_user
  after_action :set_gcm_key, :only => ["create", "destroy"]

  #AJS추가
  def get_user_data
    if current_user
      current_user_string_id = User.find_by_id(current_user.id).string_id

      my_asks_in_progress = Ask.where(:user_id => current_user.id, :be_completed => false).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, {:comments => {:include => :user}} ])

      in_progress_count = Ask.where(:user_id => current_user.id, :be_completed => false).count
      my_ask_count = Ask.where(:user_id => current_user.id).count
      my_like_ask_count = AskLike.where(:user_id => current_user.id).count
      my_vote_count = Vote.where(:user_id => current_user.id).count
      my_comment_count = Comment.where(:user_id => current_user.id).count

      alrams = Alram.where(:user_id => current_user.id).order("updated_at desc").limit(20)
      alram_count = 0
      send_users = []
      ask_owner_users = []
      comment_owner_users = []
      left_ask_thumbnails = []
      right_ask_thumbnails = []
      alrams.each do |alram|
        alram.is_read == false ? alram_count = alram_count + 1 : alram_count = alram_count
        send_user = alram.send_user_id != nil ? User.find_by_id(alram.send_user_id).string_id : ""
        ask_owner_user = alram.ask_owner_user_id != nil ? User.find_by_id(alram.ask_owner_user_id).string_id : ""
        comment_owner_user = alram.comment_owner_user_id != nil ? User.find_by_id(alram.comment_owner_user_id).string_id : ""
        left_ask_thumbnail = alram.ask_id != nil ? AskDeal.find_by_id(Ask.find_by_id(alram.ask_id).left_ask_deal_id) : ""
        right_ask_thumbnail = alram.ask_id != nil ? AskDeal.find_by_id(Ask.find_by_id(alram.ask_id).right_ask_deal_id) : ""
        send_users << send_user
        ask_owner_users << ask_owner_user
        comment_owner_users << comment_owner_user
        left_ask_thumbnails << left_ask_thumbnail
        right_ask_thumbnails << right_ask_thumbnail
      end
      render :json => {
        :my_asks_in_progress => my_asks_in_progress,
        :current_user_string_id => current_user_string_id,
        :in_progress_count => in_progress_count,
        :my_ask_count => my_ask_count,
        :my_like_ask_count => my_like_ask_count,
        :my_vote_count => my_vote_count,
        :my_comment_count => my_comment_count,
        :alram_count => alram_count,
        :alrams => alrams, :send_users => send_users, :ask_owner_users => ask_owner_users, :comment_owner_users => comment_owner_users,
        :left_ask_thumbnails => left_ask_thumbnails, :right_ask_thumbnails => right_ask_thumbnails }
    end
  end

  def get_my_asks
    if current_user
      my_asks_in_progress = Ask.where(:user_id => current_user.id, :be_completed => false).order("id desc")
      my_asks_in_progress_detail = []
      my_asks_in_progress.each do |my|
        # my_asks_in_progress_detail << my.detail_vote_count
        my_asks_in_progress_detail << Views::DetailVoteCount.average_vote_count(my.id)
      end
      render :json => {
        :my_asks_in_progress_detail => my_asks_in_progress_detail }
    end
  end

  #AJS 추가
  def alram_check
    if current_user
      alrams = Alram.where(:user_id => current_user.id).order("updated_at desc").limit(20)
      alram_count = 0
      alrams.each do |alram|
        alram.is_read == false ? alram_count = alram_count + 1 : alram_count = alram_count
      end
    end
    render :json => {:alram_count => alram_count}
  end

  def create
    self.resource = warden.authenticate(auth_options)
    if self.resource
      super
    else
      flash[:user_email] = params[:user][:email]
      flash[:custom_notice] = "입력하신 비밀번호가 틀립니다"
      redirect_to "/users/sign_in"
    end
  end

  def change_nickname
    status = "success"
    new_string_id = params[:string_id] #AJS추가
    if User.find_by_string_id(new_string_id)
      status = "fail"
    else
      current_user.update(:string_id => new_string_id)
    end
    render :json => {:status => status, :new_string_id => new_string_id}
  end


  def toggle_receive_notice
    message = "receive"
    if current_user.receive_notice_email
      current_user.update(:receive_notice_email => false)
      message = "not_receive"
    else
      current_user.update(:receive_notice_email => true)
    end
    render :json => {:message => message}
  end

  def toggle_alram_option
    message = "on"
    if User.where(:id => current_user.id).pluck(params[:alram_option])[0] == true
      current_user.update(params[:alram_option] => false)
      message = "off"
    else
      current_user.update(params[:alram_option] => true)
    end
    render :json => {:message => message}
  end

end
