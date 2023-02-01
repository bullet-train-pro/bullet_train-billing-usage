require "test_helper"

class Billing::Usage::ControllerSupportTest < ActionController::TestCase
  class ::TestingDefaultController < ApplicationController
    include Billing::Usage::ControllerSupport

    def enforced_current_limits
      head :ok
    end

    def current_limits
    end

    def root_path
      "/"
    end
  end

  def setup
    @controller = TestingDefaultController.new

    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw do
      get :enforced_current_limits, to: "testing_default#enforced_current_limits"
    end

    setup_controller_request_and_response
  end

  def teardown
    @controller = nil
    @routes = nil

    Object.send(:remove_const, :TestingDefaultController)
  end

  def test_redirects_back_if_limit_hit
    mock_limiter = Minitest::Mock.new
    mock_limiter.expect :can?, false, ["enforced_current_limits", "testing_defaults"], count: 1

    @controller.stub :current_limits, mock_limiter do
      get :enforced_current_limits
      assert_redirected_to "/"
    end
  end
end
