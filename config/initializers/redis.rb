$r = Redis.new(:host => 'localhost', :port => 6379)

# List of namespaces

# 1) story_count - global key
# 2) board:topic - set
# 3) feed:user_id - list
# 4) story:story_id - hash. kind of immutable. Read only
# 5) story:story_id:likes - list
# 6) story:story_id:dislikes - list
# 7) story:story_id:comments - list
# 8) story:story_id:comments:comment_id:likes - list
# 9) story:story_id:comments:comment_id:dislikes - list
# 10) board:topic:members - Set

# 2) Board Schema
# board:topic_name = [ # Set
#   userid,
#   userid
# ]

# 3) Feeds for user
# feed:user_id = [ # List, newer stories LPUSHed. Helps in quick retrievals.
#   sid1, sid2, sid3, ...
# ]

# Schema of story with likes, dislikes, their details
# 4) story:story_id = { # Hash
#   :by => string,
#   :by_id => string,
#   :time => string,
#   :text => string,
# }

# 5) story:story_id:likes => [ # List, newer entries LPUSHed, shows recent values first
#     {
#       :by => string,
#       :by_id => string
#     },
#     {
#       :by => string,
#       :by_id => string
#     }, ...
#   ]


# 6) story:story_id:dislikes => [ # List, newer entries LPUSHed, shows recent values first
#     {
#       :by => string,
#       :by_id => string
#     },
#     {
#       :by => string,
#       :by_id => string
#     }, ...
#   ]

# 7) story:story_id:comments => [ # List, newer entries RPUSHed. Helps retrievals in desired order
#     { # Comment no 1
#       :by => string,
#       :by_id => string,
#       :text => string,
#       :time => string
#     },
#     { # Comment no 2
#       :by => string,
#       :by_id => string,
#       :text => string,
#       :time => string,
#     }, ... # End of comment details item 2
#   ] # End of comment details

# 8) story:story_id:comments:comment_id:likes => [ newer entries LPUSHed, so that fresher values are shown first
#         {
#           :by => string,
#           :by_id => string
#         },
#         {
#           :by => string,
#           :by_id => string
#         }
#       ], # End of comment like details

# 9) story:story_id:comments:comment_id:dislikes => [ newer entries LPUSHed, so that fresher values are shown first
#         {
#           :by => string,
#           :by_id => string
#         },
#         {
#           :by => string,
#           :by_id => string
#         }
#       ] # End of comment dislike details

# User object. Not used as such
# user:[id]:details = { # Hash
#   :name => string,
#   :id => string
# }
