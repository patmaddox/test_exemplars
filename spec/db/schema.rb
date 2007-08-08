ActiveRecord::Schema.define(:version => 0) do
  create_table :chickens, :force => true do |t|
    t.column :name, :string
    t.column :age, :integer
    t.column :ssn, :string
  end
end
