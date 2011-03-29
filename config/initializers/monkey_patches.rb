#
# ActiveSupport patches
#
module ActiveSupport

  # Format the buffered logger with timestamp/severity info.
  class BufferedLogger
    NUMBER_TO_NAME_MAP  = {0=>'DEBUG', 1=>'INFO', 2=>'WARN', 3=>'ERROR', 4=>'FATAL', 5=>'UNKNOWN'}
    NUMBER_TO_COLOR_MAP = {0=>'0;37', 1=>'32', 2=>'33', 3=>'31', 4=>'31', 5=>'37'}

    def add(severity, message = nil, progname = nil, &block)
      return if @level > severity
      sevstring = NUMBER_TO_NAME_MAP[severity]
      color     = NUMBER_TO_COLOR_MAP[severity]

      message = (message || (block && block.call) || progname).to_s
      message = "\033[0;37m#{Time.now.to_s(:db)}\033[0m [\033[#{color}m" + sprintf("%-5s","#{sevstring}") + "\033[0m] #{message.strip} (pid:#{$$})\n" unless message[-1] == ?\n
      buffer << message
      auto_flush
      message
    end
  end
end


require 'active_support/core_ext/time/conversions'
module Rails
  module Rack
    # Log the request started and flush all loggers after it.
    class Logger
      include ActiveSupport::BufferedLogger::Severity
      
      def before_dispatch(env)
        request = ActionDispatch::Request.new(env)

        if request.path == '/' && request.parameters['__no_logging__'] == 'true'
          @log_level = logger.level
  		    logger.level = Logger::ERROR
        end

        path = request.fullpath

        info "\n\nStarted #{request.request_method} \"#{path}\" " \
             "for #{request.ip} at #{Time.now.to_default_s}"
      end
      def after_dispatch(env)
        logger.level = @log_level unless @log_level.nil?
        ActiveSupport::LogSubscriber.flush_all!
      end
		end
	end
end
