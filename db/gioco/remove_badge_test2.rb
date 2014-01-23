kind = Kind.find_by_name('welcome')
      badge = Badge.where( :name => 'test2', :kind_id => kind.id ).first
      badge.destroy
puts '> Badge successfully removed'