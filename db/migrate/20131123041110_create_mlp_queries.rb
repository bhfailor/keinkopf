class CreateMlpQueries < ActiveRecord::Migration
  class MlpQuery < ActiveRecord::Base
  end

  def up
    create_table :mlp_queries do |t|
      t.string :session
      t.datetime :class_start
      t.datetime :class_stop
      t.string :semester
      t.integer :section
      t.string :instructor_login_email
      t.string :instructor_password

      t.timestamps
    end

    # create defaults for everything but section number and instructor credentials
    # MlpQuery.create session: 'D',
    #                class_start: '2013-11-14 09:30:00',
    #                class_stop:  '2013-12-17 11:30:00',
    #                semester: 'FA13'

  end

  def down
    drop_table :mlp_queries
  end
end
