
RSpec.shared_examples 'a soft deletable model' do
  it { should have_db_column(:deleted_at) }

  it 'should soft delete instances' do
    instance = create described_class.name.underscore
    instance.destroy

    expect(described_class.only_deleted).to include(instance)
  end
end
