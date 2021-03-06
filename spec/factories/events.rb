# == Schema Information
#
# Table name: events
#
#  id               :integer          not null, primary key
#  name             :string
#  description      :string
#  max_participants :integer
#  date_ranges      :collection
#  published        :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  hidden           :boolean
#

FactoryGirl.define do
  factory :event do
    name "Event-Name"
    description "Event-Description"
    max_participants 1
    organizer "Workshop-Organizer"
    knowledge_level "Workshop-Knowledge Level"
    application_deadline Date.tomorrow
    custom_application_fields ["Field 1", "Field 2", "Field 3"]
    date_ranges { build_list :date_range, 1 }
    hidden false
    published true

    trait :in_the_past_valid do
      after(:build) do |event|
        event.date_ranges = [FactoryGirl.create(:date_range, :in_the_past_valid)]
      end
      name "Past Event"
      to_create {|instance| instance.save(validate: false) }
    end

    trait :with_two_date_ranges do
      after(:build) do |event|
        event.date_ranges = []
        event.date_ranges << FactoryGirl.create(:date_range, start_date: Date.tomorrow.next_day(1), end_date: Date.tomorrow.next_day(5))
        event.date_ranges << FactoryGirl.create(:date_range, start_date: Date.tomorrow.next_day(1), end_date: Date.tomorrow.next_day(10))
      end
    end

    trait :application_deadline_in_10_days do
      application_deadline Date.current.next_day(10)

      after(:build) do |event|
        event.date_ranges = [FactoryGirl.create(:date_range, start_date: Date.tomorrow.next_day(30), end_date: Date.tomorrow.next_day(30))]
      end
    end

    trait :is_only_today do
      application_deadline Date.current

      after(:build) do |event|
        event.date_ranges = [FactoryGirl.create(:date_range, start_date: Date.current, end_date: Date.current)]
      end
    end

    trait :is_only_tomorrow do
      application_deadline Date.tomorrow

      after(:build) do |event|
        event.date_ranges = [FactoryGirl.create(:date_range, start_date: Date.tomorrow, end_date: Date.tomorrow)]
      end
    end

    trait :single_day do
      after(:build) do |event|
        event.date_ranges = []
        event.date_ranges << FactoryGirl.create(:date_range, start_date: Date.tomorrow.next_day(1), end_date: Date.tomorrow.next_day(1))
      end
    end

    trait :over_six_days do
      after(:build) do |event|
        event.date_ranges = [
          FactoryGirl.create(:date_range, start_date: Date.current.next_day(1), end_date: Date.current.next_day(6))
        ]
      end
    end

    trait :with_multiple_date_ranges do
      after(:build) do |event|
        event.date_ranges = []
        event.date_ranges << FactoryGirl.create(:date_range, start_date: Date.current.next_day(3), end_date: Date.tomorrow.next_day(5))
        event.date_ranges << FactoryGirl.create(:date_range, start_date: Date.current.next_day(12), end_date: Date.current.next_day(16))
        event.date_ranges << FactoryGirl.create(:date_range, start_date: Date.current.next_day(1), end_date: Date.current.next_day(2))
      end
    end

    trait :with_unreasonably_long_range do
      after(:build) do |event|
        event.date_ranges << FactoryGirl.create(:date_range,
          start_date: Date.tomorrow,
          end_date: Date.tomorrow.next_day(Rails.configuration.unreasonably_long_event_time_span) + 8)
      end
    end

    trait :without_date_ranges do
      date_ranges { [] }
    end

    trait :with_open_application do
      after(:build) do |event, evaluator|
        create_list(:application_letter, 1, event: event)
        event.application_letters[0].user.profile = FactoryGirl.build :profile, user: event.application_letters[0].user
      end
    end

    trait :with_diverse_open_applications do
      after(:build) do |event, evaluator|
        create_list(:application_letter, 2, event: event)
      end
    end

    trait :in_draft_phase do
      after(:build) do |event|
        event.published = false
      end
    end

    trait :in_application_phase do
      after(:build) do |event|
        event.published = true
        event.application_deadline = Date.tomorrow
      end
    end

    trait :in_selection_phase_with_no_mails_sent do
      after(:build) do |event|
        event.published = true
        event.application_deadline = Date.yesterday
        event.acceptances_have_been_sent = false
        event.rejections_have_been_sent = false
      end
    end

    trait :in_selection_phase_with_no_mails_sent_and_application do
      after(:build) do |event, evaluator|
        create_list(:application_letter, 1, event: event, status: :accepted)

        event.published = true
        event.application_deadline = Date.yesterday
        event.acceptances_have_been_sent = false
        event.rejections_have_been_sent = false
      end
    end

    trait :in_selection_phase_with_participants_locked do
      after(:build) do |event|
        event.published = true
        event.application_deadline = Date.yesterday
        event.acceptances_have_been_sent = true
        event.rejections_have_been_sent = false
      end
    end

    trait :in_selection_phase_with_acceptances_sent do
      after(:build) do |event|
        event.published = true
        event.application_deadline = Date.yesterday
        event.acceptances_have_been_sent = true
        event.rejections_have_been_sent = false
      end
    end

    trait :in_selection_phase_with_rejections_sent do
      after(:build) do |event|
        event.published = true
        event.application_deadline = Date.yesterday
        event.acceptances_have_been_sent = false
        event.rejections_have_been_sent = true
      end
    end

    trait :in_execution_phase do
      after(:build) do |event|
        event.published = true
        event.application_deadline = Date.yesterday
        event.acceptances_have_been_sent = true
        event.rejections_have_been_sent = true
      end
    end

    trait :with_no_status_notification_sent do
       after(:create) do |event|
         event.application_letters.each do |application|
           application.status_notification_sent = false
           application.save! if application.changed?
         end
       end
    end

    trait :with_one_application_note do
      after(:create) do |event|
        event.application_letters = [build(:application_letter), build(:application_letter, :with_notes)]
      end
    end

    factory :event_with_accepted_applications do
      name "Event-Name"
      description "Event-Description"
      max_participants 20
      date_ranges { build_list :date_range, 1 }
      hidden false
      transient do
        accepted_application_letters_count 5
        rejected_application_letters_count 5
      end
      organizer "Workshop-Organizer"
      knowledge_level "Workshop-Knowledge Level"
      application_deadline Date.current

      after(:create) do |event, evaluator|
        create_list(:application_letter_accepted, evaluator.accepted_application_letters_count, event: event)
        create_list(:application_letter_rejected, evaluator.rejected_application_letters_count, event: event)
      end

      factory :event_with_accepted_applications_and_agreement_letters do
        after(:create) do |event, evaluator|
          create_list(:accepted_application_with_agreement_letters, evaluator.accepted_application_letters_count, event: event)
        end
      end
    end

    factory :event_with_applications_in_various_states do
      name "Event-Name"
      description "Event-Description"
      max_participants 20
      date_ranges { build_list :date_range, 1 }
      transient do
        accepted_application_letters_count 5
        rejected_application_letters_count 5
        alternative_application_letters_count 2
        canceled_application_letters_count 1
        pending_application_letters_count 0
      end
      organizer "Workshop-Organizer"
      knowledge_level "Workshop-Knowledge Level"
      application_deadline Date.current

      after(:create) do |event, evaluator|
        create_list(:application_letter_accepted, evaluator.accepted_application_letters_count, event: event)
        create_list(:application_letter_rejected, evaluator.rejected_application_letters_count, event: event)
        create_list(:application_letter_alternative, evaluator.alternative_application_letters_count, event: event)
        create_list(:application_letter_canceled, evaluator.canceled_application_letters_count, event: event)
        create_list(:application_letter_pending, evaluator.pending_application_letters_count, event: event)
      end

    end

    factory :event_in_execution_with_applications_in_various_states do
      name "Event-Name"
      description "Event-Description"
      max_participants 20
      date_ranges { build_list :date_range, 1 }
      transient do
        accepted_application_letters_count 1
        rejected_application_letters_count 1
        alternative_application_letters_count 1
        canceled_application_letters_count 1
      end
      organizer "Workshop-Organizer"
      knowledge_level "Workshop-Knowledge Level"
      application_deadline Date.current

      after(:build) do |event, evaluator|
        create_list(:application_letter_accepted, evaluator.accepted_application_letters_count, event: event)
        create_list(:application_letter_rejected, evaluator.rejected_application_letters_count, event: event)
        create_list(:application_letter_alternative, evaluator.alternative_application_letters_count, event: event)
        create_list(:application_letter_canceled, evaluator.canceled_application_letters_count, event: event)
        event.published = true
        event.application_deadline = Date.yesterday
        event.acceptances_have_been_sent = true
        event.rejections_have_been_sent = true
      end

      trait :with_no_status_notification_sent do
         after(:create) do |event|
           event.application_letters.each do |application|
             application.status_notification_sent = false
             application.save! if application.changed?
           end
         end
      end

      trait :with_status_notification_sent do
         after(:create) do |event|
           event.application_letters.each do |application|
             application.status_notification_sent = true
             application.save! if application.changed?
           end
         end
      end

    end
  end
end
