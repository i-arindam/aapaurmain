# == Schema Information
#
# Table name: add_users_to_searches
#
#  id                      :integer          not null, primary key
#  name                    :string(50)       not null
#  family_preference       :integer
#  spouse_preference       :integer
#  further_education_plans :string(500)
#  settle_else             :string(500)
#  sexual_preference       :integer          default(0)
#  virginity_opinion       :string(500)
#  hobbies                 :string(500)
#  profession              :integer
#  dream_for_future        :string(500)
#  settled_in              :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class AddUsersToSearch < ActiveRecord::Base
  # attr_accessible :title, :body
end
