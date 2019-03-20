RSpec.describe PublishPostJob, type: :job do
  let(:post) { Post.create.decorate }

  subject(:job) { described_class.perform_later(post) }

  it 'queues the job' do
    expect { job }.to have_enqueued_job(described_class).with(post.object)
  end
end
