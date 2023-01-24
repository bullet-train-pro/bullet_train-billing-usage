module Billing::UsageControllerSupport
  extend ActiveSupport::Concern

  included do
    before_action :enforce_current_limits
  end

  def enforce_current_limits
    # model ||= form.object
    # action ||= :create
    # count ||= 1
    # cancel_path ||= nil
    # if model.persisted? || current_limits.can?(action, model.class, count: count)
  end
end
