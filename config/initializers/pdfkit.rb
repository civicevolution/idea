PDFKit.configure do |config|

  config.default_options = {
      :encoding=>"UTF-8",
      :page_size=>"Letter",
      :margin_top=>"0.75in",
      :margin_right=>"0.75in",
      :margin_bottom=>"0.75in",
      :margin_left=>"0.75in",
      :disable_smart_shrinking=> false
    }

end

ActionController::Base.asset_host = Proc.new { |source, request|
  if request.format.pdf?
    "#{request.protocol}#{request.host_with_port}"
  else
    nil
  end
}