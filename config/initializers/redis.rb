$r = Redis.new(:host => 'localhost', :port => 6379)

# NOTE: All writes to REDIS HAS TO BE in json format
# --------------------------------------------------------
# LIST OF NAMESPACES
# --------------------------------------------------------

# 1) story_count - global key
# 3) feed:user_id - list
# Feed for each user. comprising story ids

# 4) story:story_id - hash. kind of immutable. Read only
# Story detail. All static data

# story:story_id:panels => set of panels for each story

# 5) story:story_id:claps - set
# user ids of actors

# 6) story:story_id:boos - set
# user ids of actors

# 7) story:story_id:comments - list
# List of comment ids from MySql.

# 8) story:story_id:comments:comment_id:claps - set
# user ids of actors

# 9) story:story_id:comments:comment_id:boos - set
# user ids of actors

# 10) panel:topic:members - Set
# List of users in each panel. Reference place

# 11) user:user_id:panels - set
# List of panels each user is part of. For reference.

# 12) user:user_id:popular_stories
# List of popular stories for each user.

# 12) user:user_id:stories - list (newer entries LPUSHed)
# List in order of time of all stories of user

# 13) panel:topic:stories - list
# List of stories in this panel



# --------------------------------------------------------
# DETAILED NAMESPACE SCHEMA
# --------------------------------------------------------

# 3) Feeds for user
# feed:user_id = [ # List, newer stories LPUSHed. Helps in quick retrievals.
#   sid1, sid2, sid3, ...
# ]

# Schema of story 
# 4) story:story_id = { # Hash
#   :by => string,
#   :by_id => string,
#   :time => string,
#   :text => string,
# }

# story:story_id:panels => [ - set
#     panel1,
#     panel2
#   ]


# 5) story:story_id:claps => [ # set of user ids
#     user1, user2, user3 ...
#   ]


# 6) story:story_id:boos => [ # List, newer entries LPUSHed, shows recent values first
#     user1, user2, user3 ...
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
#     user1, user2, user3 ...
#    ], # End of comment like details

# 9) story:story_id:comments:comment_id:boos => [ newer entries LPUSHed, so that fresher values are shown first
#     user1, user2, user3 ...
#    ] # End of comment dislike details

# 10) panel:panel_name:members - set => [
#     user_id1,
#     user_id2,
#     ...
#   ]
# 
# 11) user:user_id:panels - set => [
#     panel_name1,
#     panel_name2,
#     ...
#   ]
# 
# 12) user:user_id:popular_stories => [ newer entries LPUSHed, so that fresher content is shown first
#     story_id1,
#     story_id2,
#     ...
#   ]



# --------------------------------------------------------
# WORKFLOW IN NAMESPACES
# --------------------------------------------------------

# Workflow. - Currently *FAN-OUT-ON-WRITE* approach

# For every story created, passed in are names of panels that the story fits in.
#   Create the story
#   Add it to the user's feed as his story.
#   Add story in each panels feed.
#   For each of the listed panels
#     select all users of that panel
#     for each user add this story id in his feed


# --------------------------------------------------------
# QUESTION ANSWERS SECTION
# --------------------------------------------------------

# user:user_id:questions => [
#   {
#     :qid => id,
#     :answer => choice
#   },
#   {
#     :qid => id,
#     :answer => choice
#   },
#   ...
# ]

# question:question_id:answers => {
#   :num_choices => int,
#   :choice1 => int,
#   :choice2 => int,
#   ...
# }
