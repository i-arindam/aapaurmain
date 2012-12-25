$r = Redis.new(:host => 'localhost', :port => 6379)


# Schema of story with likes, dislikes, their details
# story:[story_id] = { # Hash
#   :by => string,
#   :by_id => string,
#   :time => string,
#   :text => string,
#   :comment_count => string,
#   :like_count => string,
#   :dislike_count => string,
# }

# story[:story_id]:likes => [ # List
#     {
#       :by => string,
#       :by_id => string
#     },
#     {
#       :by => string,
#       :by_id => string
#     }, ...
#   ]


# story[:story_id]:dislikes => [ # List
#     {
#       :by => string,
#       :by_id => string
#     },
#     {
#       :by => string,
#       :by_id => string
#     }, ...
#   ]

# story[:story_id]:comments => [ # List
#     { # Comment no 1
#       :by => string,
#       :by_id => string,
#       :text => string,
#       :time => string,
#       :comment_like_count => string,
#       :comment_likes => [ # List
#         {
#           :by => string,
#           :by_id => string
#         },
#         {
#           :by => string,
#           :by_id => string
#         }
#       ], # End of comment like details
#       :comment_dislike_count => string,
#       :comment_dislikes => [ # List
#         {
#           :by => string,
#           :by_id => string
#         },
#         {
#           :by => string,
#           :by_id => string
#         }
#       ] # End of comment dislike details
#     }, # End of comment details item 1
#     { # Comment no 2
#       :by => string,
#       :by_id => string,
#       :text => string,
#       :time => string,
#       :comment_likes => string,
#       :comment_like_details => [
#         {
#           :by => string,
#           :by_id => string
#         },
#         {
#           :by => string,
#           :by_id => string
#         }
#       ], # End of comment like details
#       :comment_dislikes => string,
#       :comment_dislike_details => [
#         {
#           :by => string,
#           :by_id => string
#         },
#         {
#           :by => string,
#           :by_id => string
#         }
#       ] # End of comment dislike details
#     }, ... # End of comment details item 2
#   ] # End of comment details
# } # End of story


# Board Schema
# board:[topic_name] = [ # Set
#   userid,
#   userid
# ]

# User object. Not used as such
# user:[id]:details = { # Hash
#   :name => string,
#   :id => string
# }
