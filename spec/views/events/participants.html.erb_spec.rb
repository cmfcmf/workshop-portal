require 'rails_helper'

RSpec.describe "events/participants", type: :view do
  before(:each) do
    @event = assign(:event, FactoryGirl.create(:event_with_accepted_applications))
    @participants = assign(:participants, @event.participants)
    sign_in(FactoryGirl.create(:user, role: :admin))
  end

  it "renders attributes" do
    render
    expect(rendered).to have_text(t(:participants, scope:'events.participants'))
    expect(rendered).to have_text(@event.participants[0].name)
  end

  it "detects missing agreement letters" do
    @user = FactoryGirl.create(:user)
    @profile = FactoryGirl.create(:profile, user: @user, birth_date: 15.years.ago)
    @event = FactoryGirl.create(:event)
    @application = FactoryGirl.create(:application_letter_accepted, user: @user, event: @event)
    assign(:event, @event)
    assign(:participants, @event.participants)
    render
    expect(rendered).to have_text(t(:unavailable, scope:'events.participants'))
  end

  it "detects available agreement letters" do
    @user = FactoryGirl.create(:user)
    @profile = FactoryGirl.create(:profile, user: @user, birth_date: 15.years.ago)
    @event = FactoryGirl.create(:event)
    @application = FactoryGirl.create(:application_letter_accepted, user: @user, event: @event)
    @agreement = FactoryGirl.create(:agreement_letter, user: @user, event: @event)
    assign(:event, @event)
    assign(:participants, @event.participants)
    render
    expect(rendered).to have_text(t(:available, scope:'events.participants'))
    expect(rendered).not_to have_text(t(:unavailable, scope:'events.participants'))
  end

  it "detects when agreement letters are unnecessary" do
    @user = FactoryGirl.create(:user)
    @profile = FactoryGirl.create(:profile, user: @user, birth_date: 19.years.ago)
    @event = FactoryGirl.create(:event)
    @application = FactoryGirl.create(:application_letter_accepted, user: @user, event: @event)
    @agreement = FactoryGirl.create(:agreement_letter, user: @user, event: @event)
    assign(:event, @event)
    assign(:participants, @event.participants)
    render
    expect(rendered).to have_text(t(:unnecessary, scope:'events.participants'))
  end

  it "displays print badges button (in event execution phase)" do
    @event = assign(:event, FactoryGirl.create(:event, :in_execution_phase))
    render
    expect(rendered).to have_link(t(:print_button_label, scope: 'events.badges', disabled: false))
  end

  it "disables the print badges button when there are no participants" do
    @event = assign(:event, FactoryGirl.create(:event, :in_execution_phase))
    @participants = []
    render
    expect(rendered).to have_link(t(:print_button_label, scope: 'events.badges', disabled: true))
  end

  it "does not show the print badges button when the event is in draft phase" do
    @event = assign(:event, FactoryGirl.create(:event_with_accepted_applications, :in_draft_phase))
    @participants = assign(:participants, @event.participants)
    render
    expect(rendered).to_not have_link(t(:print_button_label, scope: 'events.badges'))
  end

  it "does not show the print badges button when the event is in application phase" do
    @event = assign(:event, FactoryGirl.create(:event_with_accepted_applications, :in_application_phase))
    @participants = assign(:participants, @event.participants)
    render
    expect(rendered).to_not have_link(t(:print_button_label, scope: 'events.badges'))
  end

  it "does not show the print badges button when the event is in selection phase" do
    @event = assign(:event, FactoryGirl.create(:event_with_accepted_applications, :in_selection_phase_with_no_mails_sent))
    @participants = assign(:participants, @event.participants)
    render
    expect(rendered).to_not have_link(t(:print_button_label, scope: 'events.badges'))
  end

  it "displays correct groups" do
    @user = FactoryGirl.create(:user)
    @profile = FactoryGirl.create(:profile, user: @user)
    @event = FactoryGirl.create(:event)
    @application_letter = FactoryGirl.create(:application_letter_accepted, user: @user, event: @event)
    @participant_group = FactoryGirl.create(:participant_group, user: @user, event: @event)
    assign(:event, @event)
    assign(:participants, @event.participants)
    render
    expect(rendered).to have_select('participant_group_group', selected: I18n.t("participant_groups.options.#{ParticipantGroup::GROUPS[@participant_group.group]}"))
  end

  it "displays select element with all options" do
    @user = FactoryGirl.create(:user)
    @profile = FactoryGirl.create(:profile, user: @user)
    @event = FactoryGirl.create(:event)
    @application_letter = FactoryGirl.create(:application_letter_accepted, user: @user, event: @event)
    @participant_group = FactoryGirl.create(:participant_group, user: @user, event: @event)
    assign(:event, @event)
    assign(:participants, @event.participants)
    render
    expect(rendered).to have_select('participant_group_group', options: ParticipantGroup::GROUPS.map { |key, value| I18n.t("participant_groups.options.#{value}") })
  end

  it "contains a modal to print participant lists" do
    render
    expect(rendered).to have_css('div#print_participant_modal')
    expect(rendered).to have_css('button#open_print_modal')
    expect(rendered).to have_css('input#print_participant_list')
  end

  it "displays an modal that allows selection of email target" do
    render
    expect(rendered).to have_css('div#send_participant_email_modal')
  end

  it "allows selection of participants in the modal" do
    application_letter = FactoryGirl.create(:application_letter, user: FactoryGirl.create(:user_with_profile, role: :organizer), event: @event, status: 1)
    @event.application_letters.push(application_letter)
    render
    expect(rendered).to have_select('users', :with_options => [application_letter.user.profile.name])
  end
end
