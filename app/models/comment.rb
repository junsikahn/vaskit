class Comment < ActiveRecord::Base
  belongs_to :user

  after_create :incr_ask_deal_comment_count
  before_destroy :decr_ask_deal_comment_count


  def incr_ask_deal_comment_count
    ask = Ask.find_by_id(self.ask_id)
    if ask.left_ask_deal_id == self.ask_deal_id
      ask.left_ask_deal.update(:comment_count => Comment.where(:ask_deal_id => self.ask_deal_id, :is_deleted => 0).count )
    elsif ask.right_ask_deal_id == self.ask_deal_id
      ask.right_ask_deal.update(:comment_count => Comment.where(:ask_deal_id => self.ask_deal_id, :is_deleted => 0).count )
    end
  end

  def decr_ask_deal_comment_count
    ask = Ask.find_by_id(self.ask_id)
    if ask.left_ask_deal_id == self.ask_deal_id
      ask.left_ask_deal.update(:comment_count => Comment.where(:ask_deal_id => self.ask_deal_id).count - 1 )
    elsif ask.right_ask_deal_id == self.ask_deal_id
      ask.right_ask_deal.update(:comment_count => Comment.where(:ask_deal_id => self.ask_deal_id).count - 1 )
    end
  end

end
