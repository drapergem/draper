require 'minitest_helper'

if defined?(Devise)
  describe "A decorator test" do
    it "can sign in a real user" do
      user = User.new
      sign_in user

      assert_same user, helper.current_user
    end

    it "can sign in a mock user" do
      user = Object.new
      sign_in :user, user

      assert_same user, helper.current_user
    end

    it "can sign in a real admin" do
      admin = Admin.new
      sign_in admin

      assert_same admin, helper.current_admin
    end

    it "can sign in a mock admin" do
      admin = Object.new
      sign_in :admin, admin

      assert_same admin, helper.current_admin
    end

    it "can sign out a real user" do
      user = User.new
      sign_in user
      sign_out user

      assert helper.current_user.nil?
    end

    it "can sign out a mock user" do
      user = Object.new
      sign_in :user, user
      sign_out :user

      assert helper.current_user.nil?
    end

    it "can sign out without a user" do
      sign_out :user

      assert helper.current_user.nil?
    end

    it "is backwards-compatible" do
      user = Object.new
      ActiveSupport::Deprecation.silence do
        sign_in user
      end

      assert_same user, helper.current_user
    end
  end
end
