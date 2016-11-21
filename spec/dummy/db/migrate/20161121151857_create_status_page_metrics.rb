class CreateStatusPageMetrics < ActiveRecord::Migration[5.0]
  def change
    create_table :status_page_metrics do |t|
      t.string :scope
      t.float :value
      t.timestamps
    end
  end
end
