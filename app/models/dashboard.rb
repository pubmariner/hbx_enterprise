class Dashboard
  include Mongoid::Document

#	Person.all_with_multiple_members.size


# Entry.collection.map_reduce(map, reduce, { :query => { :feed_id => feed }, :out => "#{feed}.comments_by_date"})

# m = "function() { emit(this.bgn_date, 1); }"
# r = "function(k, vals) { var sum = 0; for(var i in vals) sum += vals[i]; return sum; }"
# Enrollment.map_reduce(m, r).out(inline: 1).counts


# Enrollment.collection.map_reduce(map, reduce, { :query => { :enrollment_id => enrollment }, :out => "#{feed}.comments_by_date"})


# Enrollment.map_reduce(m, r).out(inline: 1).counts

# results = Enrollment.collection.aggregate([{"$group" =>
# 																					 { "_id" => {"bgn_date" => "$bgn_date"}, "ct_of_coverage" => {"$sum" : "$age"}}}])



end
