require 'spec_helper'
require 'minitest/rails/active_support'
require 'draper/test/minitest_integration'

describe "minitest-rails spec_type Lookup Integration" do
  context "ProductDecorator" do
    it "resolves constants" do
      klass = MiniTest::Spec.spec_type(ProductDecorator)
      klass.should == MiniTest::Rails::ActiveSupport::TestCase
    end

    it "resolves strings" do
      klass = MiniTest::Spec.spec_type("ProductDecorator")
      klass.should == MiniTest::Rails::ActiveSupport::TestCase
    end
  end

  context "WidgetDecorator" do
    it "resolves constants" do
      klass = MiniTest::Spec.spec_type(WidgetDecorator)
      klass.should == MiniTest::Rails::ActiveSupport::TestCase
    end

    it "resolves strings" do
      klass = MiniTest::Spec.spec_type("WidgetDecorator")
      klass.should == MiniTest::Rails::ActiveSupport::TestCase
    end
  end

  context "decorator strings" do
    it "resolves DoesNotExistDecorator" do
      klass = MiniTest::Spec.spec_type("DoesNotExistDecorator")
      klass.should == MiniTest::Rails::ActiveSupport::TestCase
    end

    it "resolves DoesNotExistDecoratorTest" do
      klass = MiniTest::Spec.spec_type("DoesNotExistDecoratorTest")
      klass.should == MiniTest::Rails::ActiveSupport::TestCase
    end

    it "resolves Does Not Exist Decorator" do
      klass = MiniTest::Spec.spec_type("Does Not Exist Decorator")
      klass.should == MiniTest::Rails::ActiveSupport::TestCase
    end

    it "resolves Does Not Exist Decorator Test" do
      klass = MiniTest::Spec.spec_type("Does Not Exist Decorator Test")
      klass.should == MiniTest::Rails::ActiveSupport::TestCase
    end
  end

  context "non-decorators" do
    it "doesn't resolve constants" do
      klass = MiniTest::Spec.spec_type(Draper::HelperSupport)
      klass.should == MiniTest::Spec
    end

    it "doesn't resolve strings" do
      klass = MiniTest::Spec.spec_type("Nothing to see here...")
      klass.should == MiniTest::Spec
    end
  end
end
