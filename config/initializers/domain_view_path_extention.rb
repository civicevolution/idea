# this is to extend the selection of the view_path directory
# view_path will be selected based on the subdomain of the request


## I couldn't get this to work yet, but I can do a more simplistic approach for now in application_controller.rb


#require 'action_controller'
#ActionController::Base.view_paths = ["app/views", "app/views/uos", "app/views/demo", "app/views/geraldton"]



# the code example (http://www.axehomeyg.com/2009/06/10/view-path-manipulation-for-rails-with-aop/) used this, which has a warning `load_without_new_constant_marking':
# so I tried the code below w/o an error, I think it has the same effect
#ActionController::Base.class_eval
#  # Assumes a per-application/request view prioritization, not per-controller
#  cattr_accessor :application_view_path
#  self.view_paths = %w(app/views
#                       app/views/application_one
#                       app/views/application_two).map do |path| Rails.root.join(path).to_s end
#end

#class ActionController::Base
##.class_eval
###  # Assumes a per-application/request view prioritization, not per-controller
#  cattr_accessor :application_view_path
#  self.view_paths = %w(
#                      app/views/uso
#                      app/views
#                      app/view/geraldton
#                      app/views/demo).map do |path| Rails.root.join(path).to_s end
#end
#
#
#
#ActionView::PathSet.class_eval do
#  def each_with_application_view_path(&block)
#    application_view_path = ActionController::Base.application_view_path
# 
#    if application_view_path
#      # remove and prepend the view path in question to the array BEFORE proceeding with the 'each' operation
#      (select do |item|
#        item.to_s == application_view_path
#      end + reject do |item|
#        item.to_s == application_view_path
#      end).each(&block)
#    else
#      each_without_application_view_path(&block)
#    end
#  end
# 
#  # as usual, lets play nice with anything else in the call chain.
#  alias_method_chain :each, :application_view_path
#end
