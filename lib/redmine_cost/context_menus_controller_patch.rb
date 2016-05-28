require_dependency 'context_menus_controller'

module  RedmineCost
  module ContextMenusControllerPatch
    def self.included(base)

      base.class_eval do
        def cost_entries
          @cost_entries = CostEntry.where(:id => params[:ids]).preload(:project).to_a
          (render_404; return) unless @cost_entries.present?
          if (@cost_entries.size == 1)
            @cost_entry = @cost_entries.first
          end

          @projects = @cost_entries.collect(&:project).compact.uniq
          @project = @projects.first if @projects.size == 1
          @activities = CostEntryActivity.shared.active

          edit_allowed = @cost_entries.all? {|t| t.editable_by?(User.current)}
          @can = {:edit => edit_allowed, :delete => edit_allowed}
          @back = back_url

          @options_by_custom_field = {}
          if @can[:edit]
            custom_fields = @cost_entries.map(&:editable_custom_fields).reduce(:&).reject(&:multiple?)
            custom_fields.each do |field|
              values = field.possible_values_options(@projects)
              if values.present?
                @options_by_custom_field[field] = values
              end
            end
          end

          render :layout => false
        end
      end
    end
  end
end