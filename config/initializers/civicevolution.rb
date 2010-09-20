#RATING_OPTIONS = {1 => 'I hate it', 2 => "I don't like it", 3 => "It's ok", 4 => 'I like it', 5 => 'I love it'}
QUESTION_RATING_OPTIONS = {1 => 'Not answered', 2 => "Discussion has started", 3 => "Answers have started", 4 => "Answers are flowing", 
  5 => 'Good answers', 6 => 'Great answers', 7=>'Fully answered' }
ANSWER_RATING_OPTIONS = {1 => 'Not important at all', 2 => "Not too important", 3 => "Fairly important", 4 => 'Very important', 5 => 'Extremely important'}

Paperclip.interpolates :ape_code do |attachment, style|
  attachment.instance.ape_code
end