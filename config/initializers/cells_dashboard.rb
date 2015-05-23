# Defines cells for Personal Dashboard Pages
Cells::Dashboard.create(:dashboard) do
  # TODO: Add Dashboard Widgets
  add_widget 'dashboard/confirmation' do |user|
    !user.confirmed_at? && (!user.confirmation_sent_at? || user.confirmation_sent_at < 1.hour.ago)
  end

  fallback 'dashboard/empty'
end

Cells::Dashboard.create(:organisation) do
  # TODO: Add Dashboard Widgets

  fallback 'dashboard/empty'
end
