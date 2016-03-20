require_dependency 'application_helper'

module  RedmineCost
  module ApplicationHelperPatch
    def self.included(base)
      base.class_eval do
        def html_costs(text)
          text.gsub(%r{(\d+)\.(\d+)}, '<span class="hours hours-int">\1</span><span class="hours hours-dec">.\2</span>').html_safe
        end
      end
    end

  end
end
