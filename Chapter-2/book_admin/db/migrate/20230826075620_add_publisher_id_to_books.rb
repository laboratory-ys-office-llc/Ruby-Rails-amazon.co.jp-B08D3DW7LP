class AddPublisherIdToBooks < ActiveRecord::Migration[7.0]
  def change
    add_reference :books, :publisher, null: false, foreign_key: true
    change_column_null :books, :publisher_id, :integer, null: false
  end
end
