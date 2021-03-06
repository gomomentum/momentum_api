require '../lib/momentum_api'

discourse_options = {
    do_live_updates:        false,
    # target_username:        'James_Barrese',         # David_Kirk Bret_Nodine Scott_StGermain Kim_Miller David_Ashby Fernando_Venegas
    target_groups:          %w(trust_level_0),      # OpenKimono TechMods GreatX BraveHearts trust_level_0 trust_level_1
    ownership_groups:        %w(Owner Owner_Manual),
    instance:               'https://discourse.gomomentum.org',
    # instance:               'https://staging.gomomentum.org',
    api_username:           'KM_Admin',
    exclude_users:           %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin MD_Admin),
    issue_users:             %w(),
    log_file:                File.expand_path('../logs/_run.log', __FILE__)
}

# groups are 45: Onwers_Manual, 136: Owners (auto), 107: FormerOwners (expired)
master_run_config = YAML.load_file '../_run_config.yml'
schedule_options =  {ownership: master_run_config[:ownership]}
# puts schedule_options

# schedule_options = {
#     ownership:{
#         settings: {
#             all_ownership_group_ids: [45, 136]
#         },
#         manual: {
#             new_user_found: {
#                 do_task_update:         true,
#                 user_fields:            '6',
#                 ownership_code:         'NU',
#                 days_until_renews:      9999,
#                 action_sequence:        'R0',
#                 add_to_group:           108,
#                 # remove_from_group:      107,
#                 message_to:             nil,
#                 message_cc:             'KM_Admin',
#                 message_from:           'Kim_Miller',
#                 excludes:               %w()
#             },
#             new_user_one_week_ago: {
#                 do_task_update:         true,
#                 user_fields:            '6',
#                 ownership_code:         'NU',
#                 days_until_renews:      -7,
#                 action_sequence:        'R1',
#                 add_to_group:           nil,
#                 remove_from_group:      nil,
#                 message_from:           'Kim_Miller',
#                 excludes:               %w()
#             },
#             new_user_two_weeks_ago: {
#                 do_task_update:         true,
#                 user_fields:            '6',
#                 ownership_code:         'NU',
#                 days_until_renews:      -14,
#                 action_sequence:        'R2',
#                 add_to_group:           nil,
#                 remove_from_group:      nil,
#                 message_from:           'Kim_Miller',
#                 excludes:               %w()
#             },
#             new_user_three_weeks_ago: {
#                 do_task_update:         true,
#                 user_fields:            '6',
#                 ownership_code:         'NU',
#                 days_until_renews:      -21,
#                 # add_to_group:           107,
#                 # remove_from_group:      45,
#                 action_sequence:        'R3',
#                 message_cc:             'KM_Admin',
#                 message_from:           'Kim_Miller',
#                 excludes:                 %w()
#             },
#
#             zelle_new_found: {
#                 do_task_update:         true,
#                 user_fields:            '6',
#                 ownership_code:         'ZM',
#                 days_until_renews:      9999,
#                 action_sequence:        'R0',
#                 add_to_group:           45,
#                 remove_from_group:      107,
#                 message_to:             nil,
#                 message_cc:             'KM_Admin',
#                 message_from:           'Kim_Miller',
#                 excludes:               %w()
#             },
#             zelle_expires_next_week: {
#                 do_task_update:         true,
#                 user_fields:            '6',
#                 ownership_code:         'ZM',
#                 days_until_renews:      7,
#                 action_sequence:        'R1',
#                 add_to_group:           nil,
#                 remove_from_group:      nil,
#                 message_from:           'Kim_Miller',
#                 excludes:               %w()
#             },
#             zelle_expired_today: {
#                 do_task_update:         true,
#                 user_fields:            '6',
#                 ownership_code:         'ZM',
#                 days_until_renews:      0,
#                 action_sequence:        'R2',
#                 add_to_group:           nil,
#                 remove_from_group:      nil,
#                 message_from:           'Kim_Miller',
#                 excludes:               %w()
#             },
#             zelle_final: {
#                 do_task_update:         true,
#                 user_fields:            '6',
#                 ownership_code:         'ZM',
#                 days_until_renews:      -7,
#                 add_to_group:           107,
#                 remove_from_group:      45,
#                 action_sequence:        'R3',
#                 message_cc:             'KM_Admin',
#                 message_from:           'Kim_Miller',
#                 excludes:                 %w()
#             }
#         },
#
#     auto: {
#             card_auto_renew_new_subscription_found: {
#                 do_task_update:         true,
#                 user_fields:            '6',
#                 ownership_code:         'CA',
#                 days_until_renews:      9999,
#                 action_sequence:        'R0',
#                 add_to_group:           nil,
#                 remove_from_group:      107,
#                 message_to:             nil,
#                 message_cc:             'KM_Admin,Mike_Drilling',
#                 message_from:           'Kim_Miller',
#                 subscrption_name:       'Owner Auto Renewing',
#                 excludes:               %w()
#             },
#             card_auto_renew_expires_next_week: {
#                 do_task_update:         true,
#                 user_fields:            '6',
#                 ownership_code:         'CA',
#                 days_until_renews:      7,
#                 action_sequence:        'R1',
#                 add_to_group:           nil,
#                 remove_from_group:      nil,
#                 message_from:           'Kim_Miller',
#                 subscrption_name:       'Owner Auto Renewing',
#                 excludes:               %w()
#             },
#             card_auto_renew_expired_yesterday: {
#                 do_task_update:         true,
#                 user_fields:            '6',
#                 ownership_code:         'CA',
#                 days_until_renews:      -1,
#                 action_sequence:        'R2',
#                 add_to_group:           nil,
#                 remove_from_group:      nil,
#                 message_from:           'Kim_Miller',
#                 excludes:               %w()
#             },
#             card_auto_renew_expired_last_week_final: {
#                 do_task_update:         true,
#                 user_fields:            '6',
#                 ownership_code:         'CA',
#                 days_until_renews:      -7,
#                 action_sequence:        'R3',
#                 add_to_group:           107,
#                 remove_from_group:      136,
#                 message_cc:             'KM_Admin,Mike_Drilling',
#                 message_from:           'Kim_Miller',
#                 excludes:               %w()
#             }
#         }
#     }
# }

discourse_options[:logger] = momentum_api_logger(discourse_options[:log_file])
discourse = MomentumApi::Discourse.new(discourse_options, schedule_options: schedule_options)
discourse.apply_to_users
discourse.scan_summary
