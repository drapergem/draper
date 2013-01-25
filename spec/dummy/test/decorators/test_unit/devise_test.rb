require 'test_helper'

if defined?(Devise)
  class DeviseTest < Draper::TestCase
    def test_sign_in_a_real_user
      user = User.new
      sign_in user

      assert_same user, helper.current_user
    end

    def test_sign_in_a_mock_user
      user = Object.new
      sign_in :user, user

      assert_same user, helper.current_user
    end

    def test_sign_in_a_real_admin
      admin = Admin.new
      sign_in admin

      assert_same admin, helper.current_admin
    end

    def test_sign_in_a_mock_admin
      admin = Object.new
      sign_in :admin, admin

      assert_same admin, helper.current_admin
    end

    def test_sign_out_a_real_user
      user = User.new
      sign_in user
      sign_out user

      assert helper.current_user.nil?
    end

    def test_sign_out_a_mock_user
      user = Object.new
      sign_in :user, user
      sign_out :user

      assert helper.current_user.nil?
    end

    def test_sign_out_without_a_user
      sign_out :user

      assert helper.current_user.nil?
    end

    def test_backwards_compatibility
      user = Object.new
      ActiveSupport::Deprecation.silence do
        sign_in user
      end

      assert_same user, helper.current_user
    end
  end
end
