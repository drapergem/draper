require 'spec_helper'

if defined?(Devise)
  describe "A decorator spec" do
    it "can sign in a real user" do
      user = User.new
      sign_in user

      expect(helper.current_user).to be user
    end

    it "can sign in a mock user" do
      user = double("User")
      sign_in :user, user

      expect(helper.current_user).to be user
    end

    it "can sign in a real admin" do
      admin = Admin.new
      sign_in admin

      expect(helper.current_admin).to be admin
    end

    it "can sign in a mock admin" do
      admin = double("Admin")
      sign_in :admin, admin

      expect(helper.current_admin).to be admin
    end

    it "can sign out a real user" do
      user = User.new
      sign_in user
      sign_out user

      expect(helper.current_user).to be_nil
    end

    it "can sign out a mock user" do
      user = double("User")
      sign_in :user, user
      sign_out :user

      expect(helper.current_user).to be_nil
    end

    it "can sign out without a user" do
      sign_out :user

      expect(helper.current_user).to be_nil
    end

    it "is backwards-compatible" do
      user = double("User")
      ActiveSupport::Deprecation.silence do
        sign_in user
      end

      expect(helper.current_user).to be user
    end
  end
end
