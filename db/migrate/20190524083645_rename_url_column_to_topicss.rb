class RenameUrlColumnToTopicss < ActiveRecord::Migration[5.2]
  def change
    rename_column :topics, :url, :image_url
  end
end
