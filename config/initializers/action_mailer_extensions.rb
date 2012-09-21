class ActionMailer::Base

  def set_initiative_parameters
    if !args[1][:init_id].nil?
      case args[1][:init_id]
        when 1
          dir = 'cgg'
          @host = 'cgg.civicevolution.org'
          @app_name = '2029 and Beyond for Staff'
        when 2
          dir = 'cgg'
          @host = '2029.civicevolution.org'
          @app_name = '2029 and Beyond'
        when 3
          dir = 'civic'
          @host = 'civic.civicevolution.org'
          @app_name = 'CivicEvolution'
        when 4
          dir = 'ncdd'
          @host = 'ncdd.civicevolution.org'
          @app_name = 'NCDD Catalyst Awards'
        when 5
          dir = 'skyline'
          @host = 'skyline.civicevolution.org'
          @app_name = 'Skyline Students Step Up! 2012 Campaign @ CivicEvolution'
        when 6
          dir = 'civic'
          @host = 'civic.civicevolution.org'
          @app_name = '2029 and Beyond'
        when 7
          dir = 'live'
          @host = 'live.civicevolution.org'
          @app_name = 'CivicEvolution Live'
      end
      if Rails.env.development?
        @host.sub!(/\.org/, '.dev')
      end
      @template_path = dir + '/' + 'proposal_mailer'
      @template_name = args[0]
    end
  end

end