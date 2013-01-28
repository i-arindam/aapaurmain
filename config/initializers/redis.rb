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
# 10) panel:topic:members - Set
# 11) user:user_id:panel_name - set
# 12) panel:panel_name - set of user ids in this panel
# 13) user:user_id:story_id - hash

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

# 5) story:story_id:claps => [ # List, newer entries LPUSHed, shows recent values first
#     {
#       :by => string,
#       :by_id => string
#     },
#     {
#       :by => string,
#       :by_id => string
#     }, ...
#   ]


# 6) story:story_id:boos => [ # List, newer entries LPUSHed, shows recent values first
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

# 8) story:story_id:comments:comment_id:claps => [ newer entries LPUSHed, so that fresher values are shown first
#         {
#           :by => string,
#           :by_id => string
#         },
#         {
#           :by => string,
#           :by_id => string
#         }
#       ], # End of comment like details

# 9) story:story_id:comments:comment_id:boos => [ newer entries LPUSHed, so that fresher values are shown first
#         {
#           :by => string,
#           :by_id => string
#         },
#         {
#           :by => string,
#           :by_id => string
#         }
#       ] # End of comment dislike details

# 10) panel:topic:members - Set
# 11) user:user_id:panel_name - set
# 12) user:user_id:story_id - list
# 13) user:user_id:popular_stories - list of 5 top stories

# 10) panel:panel_name:members - set => [
#     user_id1,
#     user_id2,
#     ...
#   ]
# 
# 11) user:user_id:panel_name - set => [
#     panel_name1,
#     panel_name2,
#     ...
#   ]
# 
# 12) user:user_id:story_ids - list => [ newer entries LPUSHed, so that fresher content is shown first
#     story_id1,
#     story_id2,
#     ...
#   ]
# 
# 13) user:user_id:popular_stories => [ newer entries LPUSHed, so that fresher content is shown first
#     story_id1,
#     story_id2,
#     ...
#   ]
