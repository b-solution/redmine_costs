module  RedmineCost
  module ProjectsHelperPatch

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        alias_method_chain :project_settings_tabs, :your_plugin
      end
    end

    module ClassMethods
    end

    module InstanceMethods

      def project_settings_tabs_with_your_plugin
        tabs = project_settings_tabs_without_your_plugin
        tabs.push({ :name => 'red',
                    :action => :some_action,
                    :partial => 'projects/settings/costs',
                    :label => :label_cost_setting })
        return tabs
      end

    end

  end
end