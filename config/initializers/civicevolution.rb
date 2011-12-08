#RATING_OPTIONS = {1 => 'I hate it', 2 => "I don't like it", 3 => "It's ok", 4 => 'I like it', 5 => 'I love it'}
QUESTION_RATING_OPTIONS = {1 => 'Not answered', 2 => "Discussion has started", 3 => "Answers have started", 4 => "Answers are flowing", 
  5 => 'Good answers', 6 => 'Great answers', 7=>'Fully answered' }
ANSWER_RATING_OPTIONS = {1 =>  'Not important at all', 2 => "Not too important", 3 => "Fairly important", 4 => 'Very important', 5 => 'Extremely important'}

ANSWER_RATING_OPTIONS_G = {1 =>  'Strongly disagree', 2 => "Disagree", 3 => "Neutral", 4 => 'Agree', 5 => 'Strongly agree'}

TALKING_POINT_RATING_OPTIONS = {1 => 'Completely unacceptable', 2 => 'Unacceptable', 3 => "Neutral", 4 => "Acceptable", 5 =>  'Perfectly acceptable'}

Paperclip.interpolates :ape_code do |attachment, style|
  attachment.instance.ape_code
end

Paperclip.interpolates :res_base do |attachment, style|
  RES_BASE
end

Recaptcha.configure do |config|
  config.public_key  = '6Lcy0L0SAAAAAHXcETe-lnzty-iUyfYgvVp_br3Z'
  config.private_key = '6Lcy0L0SAAAAABuXgAChhDrX3aDx2Prv8WWAcZH4'
  #config.proxy = 'http://myrpoxy.com.au:8080'
end

PARTICIPATION_EVENT_POINTS = YAML.load_file("#{Rails.root}/config/participation_event_descriptions.yaml")
INITIATIVE_RESTRICTIONS = YAML.load_file("#{Rails.root}/config/initiative_restrictions.yaml")

def authorize_juggernaut_channels(session_id, channels )
  logger.debug "authorize_juggernaut_channels for session_id: #{session_id} for channels: #{@channels}"
  # read all the channels for this session_id and clear them
  old_channels = REDIS_CLIENT.HGET "session_id_channels", session_id
  if old_channels
    JSON.parse(old_channels).each do |channel|
      REDIS_CLIENT.SREM channel,session_id
    end
  end
  # add this session_id to the new channels
  channels.each do |channel|
    REDIS_CLIENT.sadd channel,session_id
  end
  REDIS_CLIENT.HSET "session_id_channels", session_id, channels
end
