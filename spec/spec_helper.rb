require 'simplecov'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([SimpleCov::Formatter::HTMLFormatter])

SimpleCov.start do
  add_filter "/spec/"
end

require 'momentum_api'
require 'rspec'
require 'json'
require 'webmock/rspec'

def discourse_options
  {
      do_live_updates:              false,
      target_username:              nil,
      target_groups:                %w(trust_level_1),
      instance:                     'live',
      api_username:                 'KM_Admin',
      exclude_users:                %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin),
      issue_users:                  %w()
  }
end

def schedule_options
  {
      category_watching:{
          matching_team:            true,
          essential:                true,
          growth_first_post:        true,
          meta_first_post:          true,
          user_group_alias:         true
      },
      trust_level_updates:          true,
      score_user_levels: {
          update_type:              'not_voted', # have_voted, not_voted, newly_voted, all
          target_post:              28707, # 28649
          # target_polls:           %w(poll), # basic new version_two
          poll_url:                 'https://discourse.gomomentum.org/t/what-s-your-score',
          messages_from:            'Kim_Miller'
      }
  }
end

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end

def json_fixture(json_file)
  json_object = File.read(fixture_path + '/' + json_file)
  JSON.parse(json_object)
end

def man_is_owner(mock_discourse, mock_dependencies, user_details, mock: mock_dependencies)
  man = MomentumApi::Man.new(mock_discourse, mock_dependencies, user_details, mock: mock_dependencies)
  man.instance_variable_set(:@is_owner, true)
  man
end