class CostEntry < ActiveRecord::Base
  unloadable

  include Redmine::SafeAttributes

  belongs_to :project
  belongs_to :issue
  belongs_to :user
  belongs_to :activity, :class_name => 'TimeEntryActivity', :foreign_key => 'activity_id'

  validates_presence_of :user_id, :project_id, :costs, :spent_on
  validates_numericality_of :costs, :allow_nil => true, :message => :invalid
  validates_length_of :comments, :maximum => 255, :allow_nil => true
  validates :spent_on, :date => true
  before_validation :set_project_if_nil


  safe_attributes 'costs', 'comments', 'project_id', 'issue_id', 'activity_id', 'spent_on'


  scope :visible, lambda {|*args|
                  if User.current.admin?
                    includes(:project).where(Project.allowed_to_condition(args.shift || User.current, :view_cost_entries, *args))
                  else
                    includes(:project).where(user_id: User.current.id)
                  end
                }
  scope :on_issue, lambda {|issue|
                   includes(:issue).where("#{Issue.table_name}.root_id = #{issue.root_id} AND #{Issue.table_name}.lft >= #{issue.lft} AND #{Issue.table_name}.rgt <= #{issue.rgt}")
                 }
  scope :on_project, lambda {|project, include_subprojects|
                     includes(:project).where(project.project_condition(include_subprojects))
                   }
  scope :spent_between, lambda {|from, to|
                        if from && to
                          where("#{TimeEntry.table_name}.spent_on BETWEEN ? AND ?", from, to)
                        elsif from
                          where("#{TimeEntry.table_name}.spent_on >= ?", from)
                        elsif to
                          where("#{TimeEntry.table_name}.spent_on <= ?", to)
                        else
                          where(nil)
                        end
                      }

  def set_project_if_nil
    self.project = issue.project if issue && project.nil?
  end

  def editable_by?(usr)
    (usr == user && usr.allowed_to?(:edit_own_cost_entries, project)) || usr.allowed_to?(:edit_cost_entries, project)
  end

  def safe_attributes=(attrs, user=User.current)
    if attrs
      attrs = super(attrs)
      if issue_id_changed? && attrs[:project_id].blank? && issue && issue.project_id != project_id
        if user.allowed_to?(:log_time, issue.project)
          self.project_id = issue.project_id
        end
      end
    end
    attrs
  end

  def hours=(h)
    write_attribute :costs, (h.is_a?(String) ? (h.to_f.round(2) || h) : h)
  end

  def costs
    h = read_attribute(:costs)
    if h.is_a?(Float)
      h.round(2)
    else
      h
    end
  end

  def spent_on=(date)
    super
    if spent_on.is_a?(Time)
      self.spent_on = spent_on.to_date
    end
    self.tyear = spent_on ? spent_on.year : nil
    self.tmonth = spent_on ? spent_on.month : nil
    self.tweek = spent_on ? Date.civil(spent_on.year, spent_on.month, spent_on.day).cweek : nil
  end

end
