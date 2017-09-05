#!/usr/bin/env python_32
import os
import mysql.connector
import time


########################## CONNECT TO SIEGMAS DATABASE ##############################
#####################################################################################

#cnx = mysql.connector.connect(user='obsun', password='deb7u1OBSUN', host='obsun-bigdata.univ.run', database='siegmas')
cnx = mysql.connector.connect(user='siegmas', password='siegmas', host='127.0.0.1', port=8889, database='siegmas')

cursor = cnx.cursor()

########################## OPEN SIMULATIONS DIR ##############################
##############################################################################

path = r'/Users/veronique/Documents/Projets/TheseAurelieGaudieux/siegmas1_4b_output'  # remove the trailing '\'
outputFilesList = []
for dir_entry in os.listdir(path):
    dir_entry_path = os.path.join(path, dir_entry)
    ext = os.path.splitext(dir_entry)[1]
    if os.path.isfile(dir_entry_path) and ext == ".csv":
        outputFilesList.append(dir_entry_path)


########################## PARSE EACH OUTPUT FILE ##############################
################################################################################


for simfile in outputFilesList:
	print("filename : "+simfile)
	#simfile = "/Users/veronique/Documents/Projets/TheseAurelieGaudieux/siegmas1_4a/plots 5.csv"
	## Open the file with read only permit
	f = open(simfile)
	## Read all lines
	lines = f.readlines()

	f.close()

	########################## READ SIMULATION INFO ##############################

	model = lines[1]
	timecreated = lines[2]
	timecreated = timecreated.split("\"")
	timecreated = timecreated[1]
	timecreated = timecreated[0:19]
	#timecreated = timecreated.replace("/","-")
	timecreated = time.strptime(timecreated, "%m/%d/%Y %H:%M:%S")
	timecreated = time.strftime("%Y-%m-%d %H:%M:%S", timecreated)

	parameters = lines[6]
	parameters = parameters.split(",")

	nbexternalhelps = parameters[7]
	nbexternalhelps = nbexternalhelps.split("\"")
	nbexternalhelps = nbexternalhelps[1]

	nboperators = parameters[2]
	nboperators = nboperators.split("\"")
	nboperators = nboperators[1]

	nbmanagers = parameters[11]
	nbmanagers = nbmanagers.split("\"")
	nbmanagers = nbmanagers[1]

	nbnaturalresources = parameters[6]
	nbnaturalresources = nbnaturalresources.split("\"")
	nbnaturalresources = nbnaturalresources[1]

	nbexploitations = parameters[13]
	nbexploitations = nbexploitations.split("\"")
	nbexploitations = nbexploitations[1]

	forestrate = parameters[14]
	forestrate = forestrate.split("\"")
	forestrate = forestrate[1]

	agriculturerate = parameters[4]
	agriculturerate = agriculturerate.split("\"")
	agriculturerate = agriculturerate[1]

	territory = parameters[12]
	territory = territory.split("\"")
	territory = territory[3]

	devianceleveltoshow = parameters[8]
	devianceleveltoshow = devianceleveltoshow.split("\"")
	devianceleveltoshow = devianceleveltoshow[1]

	nbiterate = parameters[5]
	nbiterate = nbiterate.split("\"")
	nbiterate = nbiterate[1]

	g_debug = parameters[10]
	g_debug = g_debug.split("\"")
	g_debug = g_debug[1]

	sourceFile = simfile.split("/")
	sourceFile = sourceFile[len(sourceFile)-1]


	print "model : "+model
	print "timecreated : "+timecreated
	print "nbexternalhelps : "+str(nbexternalhelps)
	print "nboperators : "+str(nboperators)
	print "nbmanagers : "+str(nbmanagers)


	# add simulation
	add_simu = ("INSERT INTO simulation "
	" (`timecreated`, `model`, `nbexternalhelps`, `nboperators`, `nbmanagers`, `nbnaturalresources`, `nbexploitations`, `forestrate`, `agriculturerate`, `territory`, `devianceleveltoshow`, `nbiterate`, `g_debug`, `sourceFile`) "
	" VALUES ('"+timecreated+"',"+model+","+nbexternalhelps+","+nboperators+","+nbmanagers+","+nbnaturalresources+","+nbexploitations+","+forestrate+","+agriculturerate+",'"+territory+"',"+devianceleveltoshow+","+nbiterate+","+g_debug+",'"+sourceFile+"')")

	print add_simu

	cursor.execute(add_simu)

	simu_id = cursor.lastrowid	#get last inserted id


	########################## READ AGENTS INFO ##############################


	# agent_02

	# agent2_name = parameters[7]
	# agent2_name = agent2_name.split("\"")
	# agent2_name = agent2_name[1]
	# agent2_name = "agent_"+agent2_name
	agent2_name = "noname"

	agent2_parameters = lines[239]
	agent2_parameters = agent2_parameters.split(",")
	agent2_simuType = agent2_parameters[4]
	agent2_simuType = agent2_simuType.split("\"")
	agent2_simuType = agent2_simuType[1]
	if agent2_simuType == "55":
		agent2_simuType = "operator"
	elif agent2_simuType == "15":
		agent2_simuType = "manager"
	else :
		agent2_simuType = "externalHelp"

	#print "agent2_name : "+agent2_name
	#print "agent2_simuType : "+agent2_simuType


	#read agent plot : store deviance values in a list of 101 elements
	agent2_values = []
	splittedLine = []
	newvalue = 0
	for i in range(243, 344):
		splittedLine = lines[i].split(",")
		newvalue = splittedLine[1]
		newvalue = newvalue.split("\"")
		newvalue = newvalue[1]
		newvalue = int(newvalue)
		agent2_values.append(newvalue)
		#print newvalue


	#add agent info
	add_agent2 = ("INSERT INTO entity "
	" (`entityType`, `name`, `simuType`) "
	" VALUES ('agent','"+agent2_name+"','"+agent2_simuType+"')")

	cursor.execute(add_agent2)

	entity_id = cursor.lastrowid #get last inserted id


	# add agent plot values
	for i in range(0, len(agent2_values)):
		add_agent2_values = ("INSERT INTO plot "
			" (`idSimu`, `idEntity`, `tick`, `correspondingDate`, `key`, `value`) "
			" VALUES ("+str(simu_id)+","+str(entity_id)+",'"+str(i)+"',NULL,'deviance','"+str(agent2_values[i])+"')")

		cursor.execute(add_agent2_values)

	# agent_05

	# agent2_name = parameters[10]
	# agent2_name = agent2_name.split("\"")
	# agent2_name = agent2_name[1]
	# agent2_name = "agent_"+agent2_name

	agent2_parameters = lines[572]
	agent2_parameters = agent2_parameters.split(",")
	agent2_simuType = agent2_parameters[4]
	agent2_simuType = agent2_simuType.split("\"")
	agent2_simuType = agent2_simuType[1]
	if agent2_simuType == "55":
		agent2_simuType = "operator"
	elif agent2_simuType == "15":
		agent2_simuType = "manager"
	else :
		agent2_simuType = "externalHelp"

	#read agents plots : store deviance values in a list of 101 elements
	agent2_values = []
	splittedLine = []
	newvalue = 0
	for i in range(576, 677):
		splittedLine = lines[i].split(",")
		newvalue = splittedLine[1]
		newvalue = newvalue.split("\"")
		newvalue = newvalue[1]
		newvalue = int(newvalue)
		agent2_values.append(newvalue)


	#add agents info
	add_agent2 = ("INSERT INTO entity "
	" (`entityType`, `name`, `simuType`) "
	" VALUES ('agent','"+agent2_name+"','"+agent2_simuType+"')")

	cursor.execute(add_agent2)

	entity_id = cursor.lastrowid #get last inserted id


	# add agent plot values
	for i in range(0, len(agent2_values)):
		add_agent2_values = ("INSERT INTO plot "
			" (`idSimu`, `idEntity`, `tick`, `correspondingDate`, `key`, `value`) "
			" VALUES ("+str(simu_id)+","+str(entity_id)+",'"+str(i)+"',NULL,'deviance','"+str(agent2_values[i])+"')")

		cursor.execute(add_agent2_values)


	# agent_01

	# agent2_name = parameters[14]
	# agent2_name = agent2_name.split("\"")
	# agent2_name = agent2_name[1]
	# agent2_name = "agent_"+agent2_name

	agent2_parameters = lines[128]
	agent2_parameters = agent2_parameters.split(",")
	agent2_simuType = agent2_parameters[4]
	agent2_simuType = agent2_simuType.split("\"")
	agent2_simuType = agent2_simuType[1]
	if agent2_simuType == "55":
		agent2_simuType = "operator"
	elif agent2_simuType == "15":
		agent2_simuType = "manager"
	else :
		agent2_simuType = "externalHelp"

	#read agents plots : store deviance values in a list of 101 elements
	agent2_values = []
	splittedLine = []
	newvalue = 0
	for i in range(132, 233):
		splittedLine = lines[i].split(",")
		newvalue = splittedLine[1]
		newvalue = newvalue.split("\"")
		newvalue = newvalue[1]
		newvalue = int(newvalue)
		agent2_values.append(newvalue)


	#add agents info
	add_agent2 = ("INSERT INTO entity "
	" (`entityType`, `name`, `simuType`) "
	" VALUES ('agent','"+agent2_name+"','"+agent2_simuType+"')")

	cursor.execute(add_agent2)

	entity_id = cursor.lastrowid #get last inserted id


	# add agent plot values
	for i in range(0, len(agent2_values)):
		add_agent2_values = ("INSERT INTO plot "
			" (`idSimu`, `idEntity`, `tick`, `correspondingDate`, `key`, `value`) "
			" VALUES ("+str(simu_id)+","+str(entity_id)+",'"+str(i)+"',NULL,'deviance','"+str(agent2_values[i])+"')")

		cursor.execute(add_agent2_values)


	# agent_06

	# agent2_name = parameters[12]
	# agent2_name = agent2_name.split("\"")
	# agent2_name = agent2_name[1]
	# agent2_name = "agent_"+agent2_name

	agent2_parameters = lines[683]
	agent2_parameters = agent2_parameters.split(",")
	agent2_simuType = agent2_parameters[4]
	agent2_simuType = agent2_simuType.split("\"")
	agent2_simuType = agent2_simuType[1]
	if agent2_simuType == "55":
		agent2_simuType = "operator"
	elif agent2_simuType == "15":
		agent2_simuType = "manager"
	else :
		agent2_simuType = "externalHelp"

	#read agents plots : store deviance values in a list of 101 elements
	agent2_values = []
	splittedLine = []
	newvalue = 0
	for i in range(687, 788):
		splittedLine = lines[i].split(",")
		newvalue = splittedLine[1]
		newvalue = newvalue.split("\"")
		newvalue = newvalue[1]
		newvalue = int(newvalue)
		agent2_values.append(newvalue)


	#add agents info
	add_agent2 = ("INSERT INTO entity "
	" (`entityType`, `name`, `simuType`) "
	" VALUES ('agent','"+agent2_name+"','"+agent2_simuType+"')")

	cursor.execute(add_agent2)

	entity_id = cursor.lastrowid #get last inserted id


	# add agent plot values
	for i in range(0, len(agent2_values)):
		add_agent2_values = ("INSERT INTO plot "
			" (`idSimu`, `idEntity`, `tick`, `correspondingDate`, `key`, `value`) "
			" VALUES ("+str(simu_id)+","+str(entity_id)+",'"+str(i)+"',NULL,'deviance','"+str(agent2_values[i])+"')")

		cursor.execute(add_agent2_values)


	# agent_03

	# agent2_name = parameters[13]
	# agent2_name = agent2_name.split("\"")
	# agent2_name = agent2_name[1]
	# agent2_name = "agent_"+agent2_name

	agent2_parameters = lines[350]
	agent2_parameters = agent2_parameters.split(",")
	agent2_simuType = agent2_parameters[4]
	agent2_simuType = agent2_simuType.split("\"")
	agent2_simuType = agent2_simuType[1]
	if agent2_simuType == "55":
		agent2_simuType = "operator"
	elif agent2_simuType == "15":
		agent2_simuType = "manager"
	else :
		agent2_simuType = "externalHelp"

	#read agents plots : store deviance values in a list of 101 elements
	agent2_values = []
	splittedLine = []
	newvalue = 0
	for i in range(354, 455):
		splittedLine = lines[i].split(",")
		newvalue = splittedLine[1]
		newvalue = newvalue.split("\"")
		newvalue = newvalue[1]
		newvalue = int(newvalue)
		agent2_values.append(newvalue)


	#add agents info
	add_agent2 = ("INSERT INTO entity "
	" (`entityType`, `name`, `simuType`) "
	" VALUES ('agent','"+agent2_name+"','"+agent2_simuType+"')")

	cursor.execute(add_agent2)

	entity_id = cursor.lastrowid #get last inserted id


	# add agent plot values
	for i in range(0, len(agent2_values)):
		add_agent2_values = ("INSERT INTO plot "
			" (`idSimu`, `idEntity`, `tick`, `correspondingDate`, `key`, `value`) "
			" VALUES ("+str(simu_id)+","+str(entity_id)+",'"+str(i)+"',NULL,'deviance','"+str(agent2_values[i])+"')")

		cursor.execute(add_agent2_values)


	# agent_04

	# agent2_name = parameters[15]
	# agent2_name = agent2_name.split("\"")
	# agent2_name = agent2_name[1]
	# agent2_name = "agent_"+agent2_name

	agent2_parameters = lines[461]
	agent2_parameters = agent2_parameters.split(",")
	agent2_simuType = agent2_parameters[4]
	agent2_simuType = agent2_simuType.split("\"")
	agent2_simuType = agent2_simuType[1]
	if agent2_simuType == "55":
		agent2_simuType = "operator"
	elif agent2_simuType == "15":
		agent2_simuType = "manager"
	else :
		agent2_simuType = "externalHelp"

	#read agents plots : store deviance values in a list of 101 elements
	agent2_values = []
	splittedLine = []
	newvalue = 0
	for i in range(465, 566):
		splittedLine = lines[i].split(",")
		newvalue = splittedLine[1]
		newvalue = newvalue.split("\"")
		newvalue = newvalue[1]
		newvalue = int(newvalue)
		agent2_values.append(newvalue)


	#add agents info
	add_agent2 = ("INSERT INTO entity "
	" (`entityType`, `name`, `simuType`) "
	" VALUES ('agent','"+agent2_name+"','"+agent2_simuType+"')")

	cursor.execute(add_agent2)

	entity_id = cursor.lastrowid #get last inserted id


	# add agent plot values
	for i in range(0, len(agent2_values)):
		add_agent2_values = ("INSERT INTO plot "
			" (`idSimu`, `idEntity`, `tick`, `correspondingDate`, `key`, `value`) "
			" VALUES ("+str(simu_id)+","+str(entity_id)+",'"+str(i)+"',NULL,'deviance','"+str(agent2_values[i])+"')")

		cursor.execute(add_agent2_values)




########################## COMMIT DB UPDATES AND CLOSE CONNEXION ##############################
###############################################################################################

cnx.commit()

cursor.close()
cnx.close()


