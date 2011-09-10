#RATING_OPTIONS = {1 => 'I hate it', 2 => "I don't like it", 3 => "It's ok", 4 => 'I like it', 5 => 'I love it'}
QUESTION_RATING_OPTIONS = {1 => 'Not answered', 2 => "Discussion has started", 3 => "Answers have started", 4 => "Answers are flowing", 
  5 => 'Good answers', 6 => 'Great answers', 7=>'Fully answered' }
ANSWER_RATING_OPTIONS = {1 =>  'Not important at all', 2 => "Not too important", 3 => "Fairly important", 4 => 'Very important', 5 => 'Extremely important'}

ANSWER_RATING_OPTIONS_G = {1 =>  'Strongly disagree', 2 => "Disagree", 3 => "Neutral", 4 => 'Agree', 5 => 'Strongly agree'}

TALKING_POINT_RATING_OPTIONS = {1 =>  'Perfectly acceptable', 2 => "Acceptable", 3 => "Neutral", 4 => 'Unacceptable', 5 => 'Completely unacceptable'}

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
