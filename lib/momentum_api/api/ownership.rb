module MomentumApi
  class Ownership

    attr_accessor :counters

    def initialize(schedule, ownership_options, mock: nil)
      raise ArgumentError, 'schedule needs to be defined' if schedule.nil?
      raise ArgumentError, 'options needs to be defined' if ownership_options.nil? or ownership_options.empty?

      # parameter setting
      @schedule               =   schedule
      @options                =   ownership_options
      @mock                   =   mock

      @message_client = @mock || MomentumApi::Messages.new(self, 'KM_Admin')

      # counter init
      @counters               =   {'Ownership': ''}
      schedule.discourse.scan_pass_counters << @counters

      zero_notifications_counters

    end

    def run(man)

      if @schedule.discourse.options[:issue_users].include?(man.user_details['username'])
        puts "#{man.user_details['username']} in Ownership"
      end

      @man = man
      clock = @mock || Date

      @options.each do |ownership_type|
        ownership_type[1].each do |action|
          renews_value = man.user_details['user_fields'][action[1][:user_fields]]
          if action[1][:excludes].include?(man.user_details['username'])
            # puts "#{man.user_details['username']} is Excluded from this Task."
          elsif renews_value  and
              Date.valid_date?(renews_value[0..3].to_i, renews_value[5..6].to_i, renews_value[8..9].to_i)

            renew_ownership_code = renews_value[11..12]
            action_ownership_code_match = renew_ownership_code == action[1][:ownership_code]

            renew_date = Date.parse(renews_value[0..9])
            action_date_qualifies = clock.today >= renew_date - action[1][:days_until_renews]

            if action_ownership_code_match

              if renews_value[14] == 'R' and renews_value[15] =~ /^\d+$/

                case ownership_type[0].to_s

                when 'manual'

                  if action_date_qualifies

                    action_sequence_last = renews_value[15].to_i
                    action_sequence_qualifies = action_sequence_last + 1 == action[1][:action_sequence][1].to_i

                    if action_sequence_qualifies

                      user_update_value = renews_value[0..12] + ' ' + action[1][:action_sequence]
                      update_ownership(man, action, user_update_value, renew_ownership_code, action[1][:action_sequence])

                      # puts Date.today.strftime("%Y-%m-%d")
                      puts ownership_type[0].to_s
                      puts action[1][:days_until_renews]
                      puts action_date_qualifies
                      puts renew_date
                      puts action_sequence_qualifies

                    end

                  end

                when 'auto'

                else
                  # puts 'No recognized ownership_type'
                end

              elsif action[1][:flag_new]
                # puts "Needs R value set #{action[0]} #{renews_value}"
                user_update_value = renews_value[0..12] + ' R0'
                update_ownership(man, action, user_update_value, renew_ownership_code, 'R0', to_username: 'Kim_Miller')
              end
              
            end

          else
            # puts 'Invalid renews_value'
          end
          
        end
      end
    end

    
    private
    
    def send_renewal_message(renew_ownership_code, current_action_seq, from_username, to_username: nil)
      message_file = renew_ownership_code + '_' + current_action_seq.to_s
      message_subject = eval(message_body(message_file + '_subject.txt'))
      message_body = eval(message_body(message_file + '_body.txt'))
      # message_client = @mock || MomentumApi::Messages.new(self, from_username) # can be moved to init
      @message_client.send_private_message(@man, message_body, message_subject, from_username: from_username, to_username: to_username)
    end

    def update_ownership(man, action, user_update_value, renew_ownership_code, current_action_seq, to_username: nil)

      # user_option_print = %w(last_seen_at last_posted_at post_count time_read recent_time_read)
      man.print_user_options(man.user_details, user_label: 'Ownership Update', nested_user_field: "#{action[1][:user_fields]}")
      @counters[:'Ownership Targets'] += 1

      update_set_value = {"#{action[1][:user_fields]}": user_update_value}

      if @schedule.discourse.options[:do_live_updates] and action[1][:do_task_update]

        send_renewal_message(renew_ownership_code, current_action_seq, action[1][:message_from], to_username: to_username)

        update_response = @schedule.discourse.admin_client.update_user(man.user_details['username'],
                                                                       user_fields: update_set_value)
        @schedule.discourse.options[:logger].warn "#{update_response[:body]['success']}"
        @counters[:'Ownership Updated'] += 1

        # check if update happened
        user_option_after_update = @schedule.discourse.admin_client.user(man.user_details['username'])
        man.print_user_options(user_option_after_update, user_label: 'User After Update', nested_user_field: "#{action[1][:user_fields]}")
        @mock ? sleep(0) : sleep(1)

      end
      # end
    end

    def message_path
      File.expand_path("../../../../ownership/messages", __FILE__)
    end

    def message_body(text_file)
      File.read(message_path + '/' + text_file)
    end

    def zero_notifications_counters
      counters[:'Ownership']              =   0
      counters[:'Ownership Targets']      =   0
      counters[:'Ownership Updated']      =   0
    end

  end
end