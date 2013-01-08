class Newsfeed < ActiveRecord::Base
  # attr_accessible :title, :body

  def self.add_story_to_feed(story_id, board)
    users_to_publish = $r.hget("board:#{board}:members")

    # This action also adds the story to the owner's feed.
    # @todo: Optimization to disregard certain kinds of trivial stories
    $r.multi do
      users_to_publish.each do |following_user_id|
        $r.lpush("feed:#{following_user_id}", story_id)
      end
    end # End multi
  end

end
