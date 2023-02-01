module Billing::Usage::ControllerSupport
  extend ActiveSupport::Concern

  included do
    before_action :enforce_current_limits
  end

  # Modeled *very* much by CanCan
  # options:
  #   action - (optional) Action to use. Defaults to the current parameterized action
  #   model - (optional) Model to use. Defaults to the RESTful controller name (pluralized) as the model (class)
  #   count - (optional) The number of objects or a method that returns a number, that will be operated against.
  #           Can be set at runtime by setting @billing_usage_count or setting this as an anonymous function or
  #           symbol as a name of the function. Defaults to 1.
  #   singleton - (optional) Use a singular (if set to true) or plural (if set to false) name for the model.
  #               Defaults to nil which means it is up to weather the action is a collection action or not..
  def enforce_current_limits(*args)
    action = params[:action]
    model = resource_class # CanCan::ControllerResource#resource_class

    puts "*********************"
    puts "DEFAULTS"
    puts "ACTION: #{action}"
    puts "MODEL: #{model}"
    puts "*********************"
    # cancel_path ||= nil
    # if model.persisted? || current_limits.can?(action, model.class, count: count)
  end

  protected

  def resource_class(*args)
    # Need to check if it is overridden...then...
    resource_name_from_controller
  end

  private

  def resource_name_from_controller
    # singularize if in a "singular controller" or if singleton is set to true
    # pluralize if in a "collection controller" or if singleton is set to false
    params[:controller].split('/').last.pluralize
  end
end