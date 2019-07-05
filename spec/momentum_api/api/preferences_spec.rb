require_relative '../../spec_helper'

describe MomentumApi::Preferences do

  let(:user_details_preference_correct) { json_fixture("user_details.json") }
  let(:user_details_preference_wrong) { json_fixture("user_details_preference_wrong.json") }
  # let(:admin_user_put) { json_fixture("admin_user_put.json") }

  user_preference_tasks = schedule_options[:user][:preferences]

  let(:mock_discourse) do
    mock_discourse = instance_double('discourse')
    expect(mock_discourse).to receive(:options).once.and_return(discourse_options)
    expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
    mock_discourse
  end

  let(:mock_schedule) do
    mock_schedule = instance_double('schedule')
    expect(mock_schedule).to receive(:discourse).exactly(2).times.and_return(mock_discourse)
    mock_schedule
  end

  let(:mock_man) do
    mock_man = instance_double('man')
    # expect(mock_man).to receive(:is_owner).exactly(1).times.and_return false
    expect(mock_man).to receive(:user_details).exactly(2).times.and_return(user_details_preference_correct)
    mock_man
  end

  describe '.preference' do

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      mock_dependencies
    end

    let(:user_perference) { MomentumApi::Preferences.new(mock_schedule, user_preference_tasks, mock: mock_dependencies) }

    context "init" do

      it ".preferences inits and responds" do
        expect(user_perference).to respond_to(:run)
        user_perference.run(mock_man)
      end
    end


    context "user already at correct preference setting" do

      it "user leaves Update Preference Targets" do
        expect(user_perference).to respond_to(:run)
        user_perference.run(mock_man)
        expect(user_perference.instance_variable_get(:@counters)[:'User Preference Targets']).to eql(0)
      end
    end


    context "user needs to be updated" do

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(2).times.and_return(discourse_options)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(3).times.and_return(mock_discourse)
        mock_schedule
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(3).times.and_return(user_details_preference_wrong)
        # expect(mock_man).to receive(:is_owner).exactly(1).times.and_return false
        expect(mock_man).to receive(:print_user_options).exactly(1).times
        mock_man
      end
      
      it "user Preference Targets updates" do
        expect(user_perference).to respond_to(:run)
                user_perference.run(mock_man)
        expect(user_perference.instance_variable_get(:@counters)[:'User Preference Targets']).to eql(1)
      end
    end


    context "do_live_updates" do

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        # expect(mock_admin_client).to receive(:user_perference).once.and_return user_details_preference_wrong
        # expect(mock_admin_client).to receive(:update_user).once.and_return admin_user_put
        mock_admin_client
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        # expect(mock_man).to receive(:discourse).exactly(1).times.and_return(mock_discourse)
        expect(mock_man).to receive(:user_details).exactly(3).times.and_return(user_details_preference_wrong)
        # expect(mock_man).to receive(:is_owner).exactly(1).times.and_return false
        expect(mock_man).to receive(:print_user_options).exactly(1).times
        mock_man
      end

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        # expect(mock_discourse).to receive(:admin_client).twice.and_return(mock_admin_client)
        expect(mock_discourse).to receive(:options).exactly(2).times.and_return(options_do_live_updates)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(3).times.and_return(mock_discourse)
        mock_schedule
      end

      it "do not do_live_updates preferences because no do_task_update" do
        expect(user_perference).to respond_to(:run)
        user_perference.run(mock_man)
      end
    end


    context "do_live_updates and do_task_update" do

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        expect(mock_admin_client).to receive(:user).once.and_return user_details_preference_correct
        expect(mock_admin_client).to receive(:update_user).once.and_return({"body": {"success": "OK"}})
        mock_admin_client
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:discourse).exactly(1).times.and_return(mock_discourse)
        expect(mock_man).to receive(:user_details).exactly(4).times.and_return(user_details_preference_wrong)
        # expect(mock_man).to receive(:is_owner).exactly(1).times.and_return false
        expect(mock_man).to receive(:print_user_options).exactly(2).times
        mock_man
      end

      user_pref_tasks_do_task_update = schedule_options[:user][:preferences]
      user_pref_tasks_do_task_update[:email_messages_level][:do_task_update] = true

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:admin_client).twice.and_return(mock_admin_client)
        expect(mock_discourse).to receive(:options).exactly(3).times.and_return(options_do_live_updates)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(5).times.and_return(mock_discourse)
        mock_schedule
      end

      let(:user_perference) { MomentumApi::Preferences.new(mock_schedule, user_pref_tasks_do_task_update, mock: mock_dependencies) }

      it "do_live_updates & do_task_update = preferences" do
        expect(user_perference).to respond_to(:run)
        user_perference.run(mock_man)
      end
    end


    context '.preferences sees issue user' do

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(3).times.and_return(user_details_preference_correct)
        # expect(mock_man).to receive(:is_owner).exactly(1).times.and_return false
        # expect(mock_man).to receive(:print_user_options).exactly(1).times
        mock_man
      end

      discourse_options_issue_user = discourse_options
      discourse_options_issue_user[:issue_users] = %w(Tony_Christopher)

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).once.and_return(discourse_options_issue_user)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(2).times.and_return(mock_discourse)
        mock_schedule
      end

      it 'sees issue user' do
        expect { user_perference.run(mock_man) }
            .to output(/Tony_Christopher in Preferences/).to_stdout
      end
    end

  end
end
