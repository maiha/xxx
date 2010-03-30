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
          it "should provide ##{name}" do
            subject.should provide(name)
          end

          if block
            describe("##{name}") do
              define_method(name) do |*args|
                subject.__send__(name, *args)
              end
              class_eval(&block)
            end
          end
        end
      end
    end
  end
end

