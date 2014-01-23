kind = Kind.find_or_create_by_name('welcome')
badge = Badge.create({ 
                      :name => 'test2', 
                      :points => '4',
                      :kind_id  => kind.id,
                      :default => 'false'
                    })
puts '> Badge successfully created'