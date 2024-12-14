# frozen_string_literal: true

module SelectRailsLog
  module Filter
    class ControllerActionFilter < BaseFilter
      filter_type :request

      define_options :controller_action_filter do
        option :pattern,
               "--controller-action NAMEs", "-A", Array,
               "Filter by controller and action names",
               "  ex: 'FooController#index,BarController,baz#show'"
      end

      def initialize(...)
        super
        @controller_actions = controller_actions(options[:pattern])
      end

      def runnable?
        !!@controller_actions
      end

      def run(data)
        @controller_actions.any? do |controller, action|
          data[CONTROLLER] == controller &&
            (action.nil? || data[ACTION] == action)
        end
      end

      private

      def controller_actions(names)
        return unless names

        names.map do |name|
          controller, action = name.split("#", 2)
          controller = classify(controller) << "Controller" unless controller.end_with?("Controller")
          [controller, action]
        end
      end

      def classify(name)
        name.scan(%r{(?:/|[^_/]+)})
            .map { |seg| seg == "/" ? "::" : seg.capitalize }
            .join
      end
    end
  end
end
