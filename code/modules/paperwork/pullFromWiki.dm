//To pull the forms from the wiki for easy editing.

//Global to store public forms (printable at the photocopier)
var/global/list/public_forms[0]

//Pulls a page from the wiki and gets the relevant data
//Called at world start in world.dm
proc/getFormsFromWiki()

	var/url = "[config.wikiurl]index.php?title=Example_Paperwork"
	var/result = shell("python scripts/pullFromWiki.py [url]")
	error("[result]")

	//Lets start the extracting and parsing
	var/page = file2text("scripts/wikiForms.txt")
	if(isnull(page) || page == "")
		error("WARNING: pulled page is empty or none")
		return

	var/list/lineList = text2list(page)

	for(var/i = 1, i <= lineList.len, i++)
		world << "[i]: [lineList[i]]"
		//End of the document.
		if(findtext(lineList[i], "NewPP") > 0)
			break
		//This we will always find before a form starts.
		if(findtext(lineList[i], "--start--") != 0)
			i++
			var/formContent
			var/formName
			while(!(findtext(lineList[i], "--stop--") != 0))
				if(findtext(lineList[i], "Branch of Operation") != 0)
					formName = lineList[i+1]
				formContent += lineList[i]
				i++
			if(!isnull(formContent) && formContent != "" && !isnull(formName) && formName != "")
				public_forms["[formName]"] = formContent

/obj/item/weapon/paper/form/publicForm/New(var/content ,date , user as mob, index = 0)
	info = content
	..()