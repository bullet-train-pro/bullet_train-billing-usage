class Billing::UsageValidator < ActiveModel::Validator
  def validate(record)
    if (record.respond_to?(:team))
      limiter = Billing::Limiter.new(record.team)
      if !limiter.can?(:create, record.class, count: 1)
        limiter.broken_hard_limits_for(:create, record.class, count: 1).each_with_index do |limit, index|
          model_name = I18n.t("#{record.class.name.underscore.pluralize}.label")
          product_name = I18n.t("billing/products.#{limit.dig(:limit, "product_id")}.name")

          record.errors.add :team, "can't add a #{model_name.singularize} because you already have #{number_with_delimiter(limit[:usage])} out of #{number_with_delimiter(limit.dig(:limit, "count"))} #{model_name.pluralize} allowed by your #{product_name} account"
        end
      end
    end
  end

  private

  def number_with_delimiter(number)
    ActiveSupport::NumberHelper.number_to_delimited(number)
  end
end

module Billing::UsageSupport
  extend ActiveSupport::Concern

  included do
    validates_with Billing::UsageValidator, on: :create
  end

  def track_billing_usage(action, model: nil, count: 1)
    model ||= self.class

    send(BulletTrain::Billing::Usage.parent_association).billing_usage_trackers.current.each do |tracker|
      tracker.track(action, model, count)
    end
  end
end
