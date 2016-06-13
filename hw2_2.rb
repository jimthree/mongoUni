require 'mongo'
require 'json'
require 'awesome_print'


DB = Mongo::Client.new(["localhost:27017"])
DKDB = DB.use(:students)
# set the logger level for the mongo driver
Mongo::Logger.logger.level = ::Logger::WARN


# the way we are going to do this is to look up the documents from each student in turn
# only returning the ones of type=homework.  we then put these homework scores into an array
# which we can easily sort.  Once sorted we take the lowest score, and use it as a key to look 
# up the document from which it came, which we then unceremoniously delete. 


def findLowestHomeworkScore()

	# we know there are 200 students, so lets iterate through each one.
	# we should query the DB to find out how many students there are, but this will do for now.
	for i in 0..199
		# create an array to hold the homework scores in
		hwScores = Array.new()

		# query the DB to find the homework documents for student 'i'
		DKDB[:grades].find({:student_id => i, :type => "homework"}).each_with_index do |homework, i|
			# insert homework scores into the array
			hwScores[i] = homework["score"]
		end

		# sort the array in place
		hwScores.sort!

		# use the first value in the now sorted array as a key to find the document in the DB
		DKDB[:grades].find({:score => hwScores[0]}).each do |lowest|
			
			puts "The lowest score that student #{lowest["student_id"]} got for #{lowest["type"]} was #{hwScores[0]}, the highest was #{hwScores[1]}" 
		
			# delete the this students homework record with the lowest score.
			DKDB[:grades].find(:score => hwScores[0]).find_one_and_delete			
		end
	end
end

#call the function.
findLowestHomeworkScore
