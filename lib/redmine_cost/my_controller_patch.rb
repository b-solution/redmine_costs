require_dependency 'my_controller'

module  RedmineCost
  module MyControllerPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do

      end
    end

  end
  module ClassMethods


  end

  module InstanceMethods
    BLOCKS = { 'issuesassignedtome' => :label_assigned_to_me_issues,
               'issuesreportedbyme' => :label_reported_issues,
               'issueswatched' => :label_watched_issues,
               'news' => :label_news_latest,
               'calendar' => :label_calendar,
               'documents' => :label_document_plural,
               'cost_entries' => :label_cost_plural,
               'timelog' => :label_spent_time
    }.merge(Redmine::Views::MyPage::Block.additional_blocks).freeze
  end

end