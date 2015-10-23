class CostEntryQuery < Query

  self.queried_class = CostEntry

  self.available_columns = [
      QueryColumn.new(:project, :sortable => "#{Project.table_name}.name", :groupable => true),
      QueryColumn.new(:spent_on, :sortable => ["#{CostEntry.table_name}.spent_on", "#{CostEntry.table_name}.created_at"], :default_order => 'desc', :groupable => true),
      QueryColumn.new(:user, :sortable => lambda {User.fields_for_order_statement}, :groupable => true),
      # QueryColumn.new(:activity, :sortable => "#{TimeEntryActivity.table_name}.position", :groupable => true),
      QueryColumn.new(:issue, :sortable => "#{Issue.table_name}.id"),
      QueryColumn.new(:comments),
      QueryColumn.new(:costs, :sortable => "#{CostEntry.table_name}.costs"),
  ]

  def initialize(attributes=nil, *args)
    super attributes
    self.filters ||= {}
    add_filter('spent_on', '*') unless filters.present?
  end

  def initialize_available_filters
    add_available_filter "spent_on", :type => :date_past

    principals = []
    if project
      principals += project.principals.sort
      unless project.leaf?
        subprojects = project.descendants.visible.all
        if subprojects.any?
          add_available_filter "subproject_id",
                               :type => :list_subprojects,
                               :values => subprojects.collect{|s| [s.name, s.id.to_s] }
          principals += Principal.member_of(subprojects)
        end
      end
    else
      if all_projects.any?
        # members of visible projects
        principals += Principal.member_of(all_projects)
        # project filter
        project_values = []
        if User.current.logged? && User.current.memberships.any?
          project_values << ["<< #{l(:label_my_projects).downcase} >>", "mine"]
        end
        project_values += all_projects_values
        add_available_filter("project_id",
                             :type => :list, :values => project_values
        ) unless project_values.empty?
      end
    end
    principals.uniq!
    principals.sort!
    users = principals.select {|p| p.is_a?(User)}

    users_values = []
    users_values << ["<< #{l(:label_me)} >>", "me"] if User.current.logged?
    users_values += users.collect{|s| [s.name, s.id.to_s] }
    add_available_filter("user_id",
                         :type => :list_optional, :values => users_values
    ) unless users_values.empty?

    # activities = (project ? project.activities : CostEntryActivity.shared.active)
    # add_available_filter("activity_id",
    #                      :type => :list, :values => activities.map {|a| [a.name, a.id.to_s]}
    # ) unless activities.empty?

    add_available_filter "comments", :type => :text
    add_available_filter "costs", :type => :float
  end

  def available_columns
    return @available_columns if @available_columns
    @available_columns = self.class.available_columns.dup
    @available_columns
  end

  def default_columns_names
    @default_columns_names ||= [:project, :spent_on, :user, :activity, :issue, :comments, :costs]
  end

  def results_scope(options={})
    order_option = [group_by_sort_order, options[:order]].flatten.reject(&:blank?)

    CostEntry.visible.
        where(statement).
        order(order_option).
        joins(joins_for_order_statement(order_option.join(',')))
  end

  def sql_for_activity_id_field(field, operator, value)
    condition_on_id = sql_for_field(field, operator, value, Enumeration.table_name, 'id')
    condition_on_parent_id = sql_for_field(field, operator, value, Enumeration.table_name, 'parent_id')
    ids = value.map(&:to_i).join(',')
    table_name = Enumeration.table_name
    if operator == '='
      "(#{table_name}.id IN (#{ids}) OR #{table_name}.parent_id IN (#{ids}))"
    else
      "(#{table_name}.id NOT IN (#{ids}) AND (#{table_name}.parent_id IS NULL OR #{table_name}.parent_id NOT IN (#{ids})))"
    end
  end

  # Accepts :from/:to params as shortcut filters
  def build_from_params(params)
    super
    if params[:from].present? && params[:to].present?
      add_filter('spent_on', '><', [params[:from], params[:to]])
    elsif params[:from].present?
      add_filter('spent_on', '>=', [params[:from]])
    elsif params[:to].present?
      add_filter('spent_on', '<=', [params[:to]])
    end
    self
  end
end
