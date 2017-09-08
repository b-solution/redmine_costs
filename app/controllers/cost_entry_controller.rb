class CostEntryController < ApplicationController
  unloadable
  before_filter :find_cost_entry, :only => [:edit, :update]
  before_filter :find_cost_entries, :only => [:destroy,:bulk_update]
  before_filter :find_optional_project, :only => [:new, :create, :index, :report]

  before_filter :authorize, :only => [:edit, :update, :destroy, :bulk_update]
  before_filter :authorize_global, :only =>  [:new, :create, :edit, :update, :destroy]


  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  helper :sort
  include SortHelper
  helper :issues
  helper :queries
  include QueriesHelper

  def index
    @query = CostEntryQuery.build_from_params(params, :project => @project, :name => '_')

    sort_init(@query.sort_criteria.empty? ? [['spent_on', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    scope = cost_entry_scope(:order => sort_clause).
        includes(:project, :user, :issue).
        preload(:issue => [:project, :tracker, :status, :assigned_to, :priority])

    respond_to do |format|
      format.html {
        @entry_count = scope.count
        @entry_pages = Paginator.new @entry_count, per_page_option, params['page']
        @entries = scope.offset(@entry_pages.offset).limit(@entry_pages.per_page).all
        @total_costs = scope.sum(:costs).to_f

        render :layout => !request.xhr?
      }
    end
  end

  def new
    @cost_entry ||= CostEntry.new(:project => @project, :issue => @issue, :user => User.current, :spent_on => User.current.today)
    @cost_entry.safe_attributes = cost_entry_params
  end

  def create
    @cost_entry ||= CostEntry.new(:project => @project, :issue => @issue, :user => User.current, :spent_on => User.current.today)
    @cost_entry.safe_attributes = cost_entry_params


    #TODO PERMISSION to add later

    # if @cost_entry.project && !User.current.allowed_to?(:log_cost, @cost_entry.project)
    #   render_403
    #   return
    # end

    call_hook(:controller_cost_entry_edit_before_save, { :params => params, :cost_entry => @cost_entry })

    if @cost_entry.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_successful_create)
          if params[:continue]
            options = {
                :cost_entry => {
                    :project_id => params[:cost_entry][:project_id],
                    :issue_id => @cost_entry.issue_id,
                    :activity_id => @cost_entry.activity_id
                },
                :back_url => params[:back_url]
            }
            if params[:project_id] && @cost_entry.project
              redirect_to new_project_cost_entry_path(@cost_entry.project, options)
            elsif params[:issue_id] && @cost_entry.issue
              redirect_to new_issue_cost_entry_path(@cost_entry.issue, options)
            else
              redirect_to new_cost_entry_path(options)
            end
          else
            redirect_back_or_default project_cost_entries_path(@cost_entry.project)
          end
        }
      end
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.api  { render_validation_errors(@cost_entry) }
      end
    end
  end

  def edit
    @cost_entry.safe_attributes = cost_entry_params
  end

  def update
    @cost_entry.safe_attributes = cost_entry_params
    if @cost_entry.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_successful_update)
          redirect_back_or_default issue_cost_entries_path(@cost_entry.issue)
        }
        format.api  { render_api_ok }
      end
    else
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.api  { render_validation_errors(@cost_entry) }
      end
    end
  end

  def report
    @query = CostEntryQuery.build_from_params(params, :project => @project, :name => '_')
    scope = cost_entry_scope

    @report = CostReportHelper.new(@project, @issue, params[:criteria], params[:columns], scope)

    respond_to do |format|
      format.html { render :layout => !request.xhr? }
    end
  end

  def destroy
    destroyed = CostEntry.transaction do
      @cost_entries.each do |t|
        unless t.destroy && t.destroyed?
          raise ActiveRecord::Rollback
        end
      end
    end

    respond_to do |format|
      format.html {
        if destroyed
          flash[:notice] = l(:notice_successful_delete)
        else
          flash[:error] = l(:notice_unable_delete_cost_entry)
        end
        redirect_back_or_default project_cost_entries_path(@projects.first)
      }
      format.api  {
        if destroyed
          render_api_ok
        else
          render_validation_errors(@cost_entries)
        end
      }
    end
  end

  def bulk_update
    attributes = parse_params_for_bulk_cost_entry_attributes(params)

    unsaved_cost_entry_ids = []
    @cost_entries.each do |cost_entry|
      cost_entry.reload
      cost_entry.safe_attributes = attributes
      call_hook(:controller_cost_entries_bulk_edit_before_save, { :params => params, :cost_entry => cost_entry })
      unless cost_entry.save
        logger.info "cost entry could not be updated: #{cost_entry.errors.full_messages}" if logger && logger.info
        # Keep unsaved cost_entry ids to display them in flash error
        unsaved_cost_entry_ids << cost_entry.id
      end
    end
    set_flash_from_bulk_cost_entry_save(@cost_entries, unsaved_cost_entry_ids)
    redirect_back_or_default project_cost_entries_path(@projects.first)
  end

  private
  def find_cost_entry
    @cost_entry = CostEntry.find(params[:id])
    @issue = @cost_entry.issue
    @project = @cost_entry.project
    unless User.current.admin?
      if @cost_entry.user_id != User.current.id
        deny_access #unless User.current.allowed_to?(:edit_cost_entries, @project)
      end
    end
  end

  def find_cost_entries
    @cost_entries = CostEntry.where(:id => params[:id] || params[:ids]).all
    raise ActiveRecord::RecordNotFound if @cost_entries.empty?
    raise Unauthorized unless @cost_entries.all? {|t| t.editable_by?(User.current)}
    @projects = @cost_entries.collect(&:project).compact.uniq
    @project = @projects.first if @projects.size == 1
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def cost_entry_scope(options={})
    scope = @query.results_scope(options)
    if @issue
      scope = scope.on_issue(@issue)
    end
    if @project
      scope = scope.on_project(@project, @project.herit_cost)
    end
    scope
  end

  def find_optional_project
    if params[:issue_id].present?
      @issue = Issue.find(params[:issue_id])
      @project = @issue.project
    elsif params[:project_id].present?
      @project = Project.find(params[:project_id])
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def set_flash_from_bulk_cost_entry_save(cost_entries, unsaved_cost_entry_ids)
    if unsaved_cost_entry_ids.empty?
      flash[:notice] = l(:notice_successful_update) unless cost_entries.empty?
    else
      flash[:error] = l(:notice_failed_to_save_cost_entries,
                        :count => unsaved_cost_entry_ids.size,
                        :total => cost_entries.size,
                        :ids => '#' + unsaved_cost_entry_ids.join(', #'))
    end
  end


  def parse_params_for_bulk_cost_entry_attributes(params)
    attributes = (cost_entry_params || {}).reject {|k,v| v.blank?}
    attributes.keys.each {|k| attributes[k] = '' if attributes[k] == 'none'}
    attributes[:custom_field_values].reject! {|k,v| v.blank?} if attributes[:custom_field_values]
    attributes
  end

  def cost_entry_params
    Redmine::VERSION::MAJOR >= 3 ? params[:cost_entry].permit! : params[:cost_entry]
  end
end

