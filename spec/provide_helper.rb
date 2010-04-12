######################################################################
### provide matcher

Spec::Matchers.define :provide do |expected|
  match do |obj|
    !!(obj.method(expected) rescue false)
  end
end

module Spec
  module Example
    module Subject
      module ExampleGroupMethods
        # == Usage
        #   describe Foo do
        #     # Foo should have instance method named 'foo'
        #     provide_instance_method :foo
        #     provide :foo    # same as 'foo', '#foo'
        #
        #     # Foo should have class method named 'foo'
        #     provide_class_method :foo
        #     provide '.foo'
        #
        # == Examples
        #
        #   class Convert
        #     private
        #       def execute(value)
        #
        # 'provide' method checks whether subject has it
        #
        #   describe Convert do
        #     provide :execute   # 1)
        #
        #   [instead of]
        #
        #   describe Convert do
        #     it "should provide #execute" do
        #       subject.should provide(:execute)
        #
        #
        # Further more, it provides two features when block given
        #   1) defines a new context for it
        #   2) creates helper method for it (useful for private method)
        #
        #   describe Convert do
        #     provide :execute do
        #       it "should return nil when nil is given" do
        #         execute(nil).should == nil
        #
        #   [instead of]
        #
        #   describe Convert do
        #     describe "#execute" do                               # 1)
        #       it "should return nil when nil is given" do
        #         subject.__send__(:execute, nil).should == nil    # 2)
        #
        def provide(name, &block)
          case name.to_s
          when /^\./            # class method
            provide_class_method($', &block)
          else
            provide_instance_method(name.to_s.sub(/^#/,''), &block)
          end
        end

        def provide_class_method(name, &block)
          klass = described_class.is_a?(Class) ? described_class : nil
          it "should provide .#{name}" do
            if klass
              klass.should provide(name)
            else
              subject.should provide(name)
            end
          end

          if block
            describe(".#{name}") do
              define_method(name) do |*args|
                subject.__send__(name, *args)
              end
              class_eval(&block)
            end
          end
        end

        def provide_instance_method(name, &block)
          klass = described_class.is_a?(Class) ? described_class : nil
          it "should provide ##{name}" do
            if klass
              (!!(klass.instance_method(name) rescue false)).should == true
            else
              subject.should provide(name)
            end
          end

          if block
            describe("##{name}") do
              unless instance_methods.include?(name.to_s)
                define_method(name) do |*args|
                  subject.__send__(name, *args)
                end
              end
              class_eval(&block)
            end
          end
        end
      end
    end
  end
end

