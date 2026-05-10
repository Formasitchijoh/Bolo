class MakeLatitudeLongitudeNullableOnTechnicians < ActiveRecord::Migration[8.1]
  def change
    change_column_null :technicians, :latitude, true
    change_column_null :technicians, :longitude, true
  end
end
