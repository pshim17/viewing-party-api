class AddHostToUserViewingParties < ActiveRecord::Migration[7.1]
  def change
    add_column :user_viewing_parties, :host, :boolean
  end
end
