# coding : utf-8
class EtcController < ApplicationController

  def landing
  end

  def access_term
  end

  def privacy_policy
  end

  def inquiry
  end

  def create_inquiry
    inquiry = Inquiry.create(:user_id => current_user.id, :message => params[:message], :contact => params[:contact])
    AdminMailer.delay.inquiry_submitted(inquiry)
    render :json => {:status => "success" }
  end

  def help
  end

  def user
    @my_ask_count = Ask.where(:user_id => current_user.id).count
    @my_vote_count = Vote.where(:user_id => current_user.id).count
    @my_comment_count = Comment.where(:user_id => current_user.id).count
    @in_progress_count = Ask.where(:user_id => current_user.id, :be_completed => false).count
    @alram_count = Alram.where(:user_id => current_user.id, :is_read => false).count
  end

end
