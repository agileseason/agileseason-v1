describe Modal::Comment do
  let(:event) { Modal::Event.new(github_event) }
  let(:github_event) do
    OpenStruct.new(
      id: 102,
      event: event_name,
      actor: stub_user,
      created_at: Time.current
    )
  end

  describe '#to_h' do
    subject { event.to_h }

    context 'opened' do
      let(:event_name) { 'opened_fake' }

      it do
        is_expected.to eq ({
          id: github_event.id,
          type: :event,
          text: 'opened this issue less than a minute ago',
          created_at: github_event.created_at,
          created_at_str: github_event.created_at.to_s,
          user: github_event.actor.to_h
        })
      end
    end

    context 'closed' do
      let(:event_name) { 'closed' }

      it do
        is_expected.to eq ({
          id: github_event.id,
          type: :event,
          text: 'closed this less than a minute ago',
          created_at: github_event.created_at,
          created_at_str: github_event.created_at.to_s,
          user: github_event.actor.to_h
        })
      end
    end

    context 'reopened' do
      let(:event_name) { 'reopened' }

      it do
        is_expected.to eq ({
          id: github_event.id,
          type: :event,
          text: 'reopened this less than a minute ago',
          created_at: github_event.created_at,
          created_at_str: github_event.created_at.to_s,
          user: github_event.actor.to_h
        })
      end
    end

    context 'unknown event' do
      let(:event_name) { 'add_label' }

      it do
        is_expected.to eq ({
          id: github_event.id,
          type: :event,
          text: 'event less than a minute ago',
          created_at: github_event.created_at,
          created_at_str: github_event.created_at.to_s,
          user: github_event.actor.to_h
        })
      end
    end
  end
end
