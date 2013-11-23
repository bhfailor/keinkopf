class RemovePassword < ActiveRecord::Migration
  def up
    remove_column :mlp_queries, :instructor_login_email
    remove_column :mlp_queries, :instructor_password
    add_column :mlp_queries, :mlp_login_email, :string

    # create defaults for everything
    MlpQuery.create session: 'D',
                    class_start: '2013-11-14 09:30:00',
                    class_stop:  '2013-12-17 11:30:00',
                    semester: 'FA13',
                    section: 72,
                    mlp_login_email: 'bhf2689@email.vccs.edu'
  end

  def down
    add_column :mlp_queries, :instructor_login_email, :string
    add_column :mlp_queries, :instructor_password, :string
    remove_column :mlp_queries, :mlp_login_email, :string
  end
end
