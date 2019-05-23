require '../utility/momentum_api'
require '../users/trust_level'
require '../notifications/users_update_global_category_watching'
require '../users_scores/user_scoring'


def print_user(user, category, group_name, notify_level)
  field_settings = "%-18s %-20s %-20s %-10s %-15s\n"
  printf field_settings, 'UserName', 'Group', 'Category', 'Level', 'Status'
  printf field_settings, user['username'], group_name, category['slug'], notify_level.to_s.center(5), 'NOT_Watching'
end

# def print_user_options(user_details, user_option_print, user_label='UserName')
#   field_settings = "%-18s %-14s %-16s %-12s %-12s %-17s %-14s\n"
#   printf field_settings, user_label,
#          user_option_print[0], user_option_print[1], user_option_print[2],
#          user_option_print[3], user_option_print[4], user_option_print[5]
#
#   printf field_settings, user_details['username'],
#          user_details[user_option_print[0].to_s].to_s[0..9], user_details[user_option_print[1].to_s].to_s[0..9],
#          user_details[user_option_print[2].to_s], user_details[user_option_print[3].to_s],
#          user_details[user_option_print[4].to_s], user_details[user_option_print[5].to_s]
# end

def category_cases(client, user, users_categories, group_name)
  @starting_categories_updated = @categories_updated

  users_categories.each do |category|

    if @issue_users.include?(user['username'])
      puts "\n#{user['username']}  Category case on category: #{category['slug']}\n"
    end

    case
    when category['slug'] == 'Essential'    # Task #2
      case_excludes = %w(Steve_Scott)
      if case_excludes.include?(user['username'])
        # puts "#{user['username']} specifically excluded from Essential Watching"
      else                            # 4 = Watching first post, 3 = Watching, 1 = blank or ...?
        set_category_notification(user, category, client, group_name, [3], 3, do_live_updates=@do_live_updates)
      end

    when category['slug'] == 'Growth'       # Task #3
      case_excludes = %w(Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
      if case_excludes.include?(user['username'])
        # puts "#{user['username']} specifically excluded from Watching Growth"
      else
        set_category_notification(user, category, client, group_name, [3, 4], 4, do_live_updates=@do_live_updates)
      end

    when category['slug'] == 'Meta'         # Task #4
      case_excludes = %w(Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
      if case_excludes.include?(user['username'])
        # puts "#{user['username']} specifically excluded from Watching Meta"
      else
        set_category_notification(user, category, client, group_name, [3, 4], 4, do_live_updates=@do_live_updates)
      end

    else
      # puts 'Category not a target'
    end
  end
  if @categories_updated > @starting_categories_updated
    @users_updated += 1
  end
end

def apply_function(user, admin_client, user_client='')
  @user_count += 1
  # printf "%s\n", user['username']
  user_details = user_client.user(user['username'])
  sleep(2)
  users_groups = user_details['groups']
  users_categories = user_client.categories
  sleep(2)

  is_owner = false
  if @issue_users.include?(user['username'])
    puts "#{user['username']} in apply_function"
  end

  # Examine Users Groups
  users_groups.each do |group|
    group_name = group['name']

    if @issue_users.include?(user['username'])
      puts "\n#{user['username']}  with group: #{group_name}\n"
    end

    # Group Filtered Category Case
    if @target_groups and @target_groups.include?(group_name)
        category_cases(user_client, user, users_categories, group_name)
    end

    # Group Cases (make a method)
    case
    when group_name == 'Owner'
      is_owner = true
    else
      # puts 'No Group Case'
    end
  end

  # Unfiltered category case
  if @target_groups
    # puts 'Not group filter'
  else
    category_cases(user_client, user, users_categories, 'Any')
  end

  # Update Trust Level           # Task #1
  update_trust_level(admin_client, is_owner, 0, user, user_details, do_live_updates=@do_live_updates)

  # User Scoring                 # Task #5
  update_type = 'newly_voted'      # have_voted, not_voted, newly_voted, all
  target_post = 28707            # 28649
  target_polls = %w(version_two) # basic new version_two
  poll_url = 'https://discourse.gomomentum.org/t/user-persona-survey/6485/20'
  scan_users_score(user_client, user, target_post, target_polls, poll_url, update_type=update_type, do_live_updates=@do_live_updates)

end

def run_tasks_for_all_users(do_live_updates=false)
  @do_live_updates = do_live_updates

  zero_counters

  if @target_groups
    @target_groups.each do |group_plug|
      apply_to_group_users(group_plug, needs_user_client=true, skip_staged_user=true)
    end
  else
    apply_to_all_users(needs_user_client=true)
  end

end

if __FILE__ == $0

  do_live_updates = false
  @instance = 'live' # 'live' or 'local'
  @emails_from_username = 'Kim_Miller'

  @exclude_user_names = %w(system discobot js_admin sl_admin JP_Admin admin_sscott RH_admin KM_Admin Winston_Churchill
                            Joe_Sabolefski)

  # testing variables
  # @target_username = 'Kim_Miller' # John_Oberstar Randy_Horton Steve_Scott Marty_Fauth Joe_Sabolefski Don_Morgan
  @target_groups = %w(Mods)  # GreatX BraveHearts trust_level_1 trust_level_0 hit 100 record limit.
  @issue_users = %w() # past in debug issue user_names Brad_Fino

  @user_count, @user_targets, @voter_targets, @new_user_score_targets, @users_updated, @user_not_voted_targets, @new_user_badge_targets,
      @sent_messages, @skipped_users, @matching_category_notify_users, @matching_categories_count,
      @categories_updated = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

  run_tasks_for_all_users(do_live_updates=do_live_updates)

  scan_summary

end
