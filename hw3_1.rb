require 'mongo'
require 'json'
require 'awesome_print'


DB = Mongo::Client.new(["localhost:27017"])
DKDB = DB.use(:school)
# set the logger level for the mongo driver
Mongo::Logger.logger.level = ::Logger::WARN


# Write a program in the language of your choice that will remove the lowest homework score 
# for each student. Since there is a single document for each student containing an array 
# of scores, you will need to update the scores array and remove the homework.

=begin

{
	"_id" : 5,
	"name" : "Wilburn Spiess",
	"scores" : [
		{
			"type" : "exam",
			"score" : 44.87186330181261
		},
		{
			"type" : "quiz",
			"score" : 25.72395114668016
		},
		{
			"type" : "homework",
			"score" : 10.53058536508186
		},
		{
			"type" : "homework",
			"score" : 63.42288310628662
		}
	]
}

=end



def findLowestHomeworkScore()

	# we know there are 200 students, so lets iterate through each one.
	# we should query the DB to find out how many students there are, but this will do for now.
	for i in 0..199

		puts "\n\n\n\n-------------------------------------\nStudent _id: #{i}\n-------------------------------------\n"
		# query the DB to find the document for student 'i'
		student = DKDB[:students].find({:_id => i})
		
		student.each do |doc|	
			# dump the entire doc out to the screen for the lulz
			ap doc
		
			# Create a socres array to put the score into.
			puts doc[:name]
			scores = Array.new()
			# iterate through each score in the documents array 
			doc[:scores].each_with_index do |score, i|
				# if the doc is over type 'homework' put it in the array
				if score[:type] == "homework"
					puts "homework-> #{score[:score]}"
					scores[i] = score[:score]
				end
			end
			
			# because the way the insert into array works, we have to
			# compact the array in place to remove the nill values 
			scores.compact!
			# then sort the array in place			
			scores.sort!
			

			# remove the lowest score (which we now know is scores[0])
			removeScoreFromDB(doc[:_id], scores[0])

		end
		puts "\n===========================================\n\n\n"

	end
end


def removeScoreFromDB(id, score)
	puts "\n\n----> the score to remove for id #{id} is #{score}\n\n"
	DKDB[:students].find_one_and_update({ :_id => id }, { '$pull' => {'scores' => {'score' => score }}} )
end


# call the main function.
findLowestHomeworkScore

