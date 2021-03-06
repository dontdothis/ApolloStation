/datum/controller/process/disease

/datum/controller/process/disease/setup()
	name = "disease"
	schedule_interval = 30 // every 3 seconds

/datum/controller/process/disease/doWork()
	for(var/datum/disease/D in active_diseases)
		if(!D.gcDestroyed)
			D.process()
			continue
		active_diseases.Remove(D)

/datum/controller/process/disease/getContext()
	return ..()+" - (AMT:[active_diseases.len])"
