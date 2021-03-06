module MomentumApi
  class WatchCategory

    attr_accessor :counters, :options

    def initialize(schedule, watching_options, mock: nil)
      raise ArgumentError, 'schedule needs to be defined' if schedule.nil?
      raise ArgumentError, 'options needs to be defined' if watching_options.nil? or watching_options.empty?

      # parameter setting
      @schedule               =   schedule
      @options                =   watching_options
      @mock                   =   mock

      # counter init
      @counters               =   {'Watch Categories': ''}
      schedule.discourse.scan_pass_counters << @counters

      zero_notifications_counters

    end

    def run(man, category, action, group_name:nil)
      if not action[:allowed_levels].include?(category['notification_level'])
        print_user(man, category['slug'], group_name, category['notification_level'], status='NOT Watching', type='CategoryUser')

        @counters[:'Category Update Targets'] += 1
        if @schedule.discourse.options[:do_live_updates] and action[:do_task_update]
          update_response = man.user_client.category_set_user_notification(id: category['id'], notification_level: action[:set_level])
          @mock ? sleep(0) : sleep(1)
          man.discourse.options[:logger].warn update_response
          @counters[:'Category Notify Updated'] += 1

          # check if update happened ... or ... comment out for no check after update
          user_details_after_update = man.user_client.categories
          @mock ? sleep(0) : sleep(1)
          user_details_after_update.each do |users_category_second_pass|
            new_category_slug = users_category_second_pass['slug']
            if category['slug'] == new_category_slug
              man.discourse.options[:logger].warn "Updated Category: #{new_category_slug}    Notification Level: #{users_category_second_pass['notification_level']}"
            end
          end
        end
      else
        if @schedule.discourse.options[:issue_users].include?(man.user_details['username'])
          puts "#{man.user_details['username']} already Watching"
        end
      end
      @counters[:'User Categories'] += 1
    end
    
    def print_user(man, category_slug, group_name, notify_level, status='', type='UserName')
      field_settings = "%-18s %-20s %-20s %-10s %-30s"
      heading = sprintf field_settings, type, 'Group', 'Category', 'Level', 'Status'
      body = sprintf field_settings, man.user_details['username'], group_name, category_slug, notify_level.to_s.center(5), status
      man.discourse.options[:logger].info heading
      man.discourse.options[:logger].info body
    end

    def zero_notifications_counters
      counters[:'User Categories']          =   0     # interesting we don't need the @instance in front
      counters[:'Category Update Targets']  =   0
      counters[:'Category Notify Updated']  =   0
    end

  end
end
