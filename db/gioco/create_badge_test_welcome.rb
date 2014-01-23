kind = Kind.find_or_create_by_name('welcome')
badge = Badge.create({ 
                      :name => 'test', 
                      :points => '2',
                      :kind_id  => kind.id,
                      :default => 'false'
                    })
puts '> Badge successfully created'