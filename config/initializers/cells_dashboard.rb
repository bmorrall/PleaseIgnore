# Defines cells for Personal Dashboard Pages
Cells::Dashboard.create(:dashboard) do
  # TODO: Add Dashboard Widgets

  fallback 'dashboard/empty'
end

Cells::Dashboard.create(:organisation) do
  # TODO: Add Dashboard Widgets

  fallback 'dashboard/empty'
end
