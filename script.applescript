on run {input, parameters}
	--Now this script is in Github
	
	#SELECTION DU NOM DU CLIENT DE LA RÉFÉRENCE
	set lsresult to do shell script "find /Volumes/VIDEOS_TMP/PRODUCTION_PremierePro -mindepth 1  -maxdepth 1 -type d -exec basename {} \\; | grep -v 00_ | grep -v Corbeille | sort"
	set AppleScript's text item delimiters to {return & linefeed, return, linefeed, character id 8233, character id 8232}
	set allClientName to (every text item in lsresult) as list
	set clientName to choose from list allClientName with prompt "Selectionner le nom du client de la référence:"
	if clientName is false then
		return
	end if
	set specialProject to "SPECIAL_PROJECT"
	if clientName contains specialProject then
		set lsresultSP to do shell script "find /Volumes/VIDEOS_TMP/PRODUCTION_PremierePro/SPECIAL_PROJECT/01_CLIENTS -mindepth 1  -maxdepth 1 -type d -exec basename {} \\; | grep -v 00_ | sort"
		set allClientName to (every text item in lsresultSP) as list
		set clientName to choose from list allClientName with prompt "Selectionner le nom du client de la référence:"
		if clientName is false then
			return
		end if
	end if
	
	#CRÉATION DU DOSSIER PORTANT LE NOM DU ZIP
	set currentFile to (item 1 of input)
	set fileInfo to info for currentFile # fileInfo = infos du finder
	set fileName to name of fileInfo # fileName = nom complet du zip
	set originPathZip to (POSIX path of currentFile)
	set AppleScript's text item delimiters to {"."}
	set NameComponents to (every text item in fileName) as list
	set fileNameWithoutZip to (item 1 of NameComponents) as string
	set rootNameUsers to POSIX path of (path to home folder)
	set rootFolder to rootNameUsers & "/Downloads"
	set pathExtractZip to (quoted form of (rootFolder & "/" & fileNameWithoutZip))
	do shell script "mkdir -p " & pathExtractZip
	
	
	#UNZIP DU ZIP DANS LE DOSSIER PORTANT LE NOM DU ZIP
	do shell script "unzip -u " & (quoted form of originPathZip) & " -d " & pathExtractZip
	
	
	#CRÉATION DES SOUS-DOSSIERS
	set AppleScript's text item delimiters to {"-"}
	set fileNameComponents to (every text item in fileNameWithoutZip) as list
	set refid to (item 1 of fileNameComponents) as string
	
	
	#DÉFINITION DU FORMAT D'AFFICHAGE DE LA DATE ACTUELLE
	tell (current date)
		set strMonth to (its month as integer)
		set strDay to (its day as integer)
		set stryear to (its year as integer)
	end tell
	set currentDate to stryear & strMonth & strDay
	
	
	#CRÉATION DU DOSSIER DE DESTINATION DES DOUBLURES
	set rootDirFolder to rootNameUsers & "/Documents/Meerobot/VIDEO"
	set destination to (quoted form of (rootDirFolder & "/" & currentDate & "/" & clientName & "/" & refid))
	do shell script "mkdir -p " & destination
	set pathPhotosFolder to destination & "/01_Photos"
	do shell script "mkdir -p " & pathPhotosFolder
	set pathVideoFolder to destination & "/02_MEDIAS"
	do shell script "mkdir -p " & pathVideoFolder
	
	
	#TRIS ET DÉPLACEMENT DES FICHIERS DANS SOUS-DOSSIERS
	do shell script "find -E " & pathExtractZip & " -regex '.*\\.(jpg|jpeg|cr2|arw|raf|rw2|pef|dng|nef|tiff|png|pdf)' -exec mv {} " & pathPhotosFolder & " \\;" #cheche les photos et les déplace dans pathPhotosFolder
	do shell script "find -E " & pathExtractZip & " -regex '.*\\.(mov|mp4|avi|flv|wmv|mpg|mts)' -exec mv {} " & pathVideoFolder & " \\;" #cheche les vidéos et les déplace dans pathVideoFolder
	
	
	#NOTIFACTION DE FIN DU UNZIP
	display notification "Le fichier de la référence à bien été dézipper et les dossier de doublures sont créé et trié" with title "Unzip et Doublure"
	
	
	#DÉPLACEMENT DANS LA CORBEILLE DES DOSSIERS VIDES ET DU FICHIER ZIP
	set pathTrash to "/Users/Marilou 1/.Trash"
	#tell application "System Events" to move currentFile to pathTrash # => FONCTIONNEL // envoie le zip dans la corbeille
	tell application "Finder" to delete ((POSIX file (rootFolder & "/" & fileNameWithoutZip)) as alias) # => FONCTIONNEL
	
	
	
	
	#SUITE DU SCRIPT // CRÉER DOSSIER PROJET SUR LE NAS
	
	
	
	
	display dialog "Créer un dossier de projet portant le nom de la référence du Shoot dans le NAS" with icon note buttons {"Non", "Oui"} with title "Dossier de Projet NAS"
	if the button returned of the result is "Non" then
		return
	end if
	
	
	#CRÉATION DU DOSSIER PORTANT LE NOM DE LA RÉFÉRENCE DU SHOOT
	set pathNasClientName to "/Volumes/VIDEOS_TMP/PRODUCTION_PremierePro" & "/" & clientName --selectionne le chemin d'accès en fonction du nom du client définie dans le diplay dialog au début du script
	if clientName does not contain lsresult then
		set pathNasClientName to "/Volumes/VIDEOS_TMP/PRODUCTION_PremierePro/SPECIAL_PROJECT/01_CLIENTS" & "/" & clientName
	end if
	set pathNasRefId to pathNasClientName & "/01_REFERENCES/" & refid
	do shell script "mkdir " & pathNasRefId
	
	
	#CRÉATION DES SOUS DOSSIERS DU PROJET
	set nasPathProjet to (quoted form of pathNasRefId) & "/" & "01_PROJET"
	do shell script "mkdir " & nasPathProjet
	set nasPathElement to (quoted form of pathNasRefId) & "/" & "03_ELEMENTS"
	do shell script "mkdir " & nasPathElement
	set nasPathLogo to (quoted form of pathNasRefId) & "/" & "03_ELEMENTS" & "/" & "01_Logo"
	do shell script "mkdir " & nasPathLogo
	set nasPathMusic to (quoted form of pathNasRefId) & "/" & "03_ELEMENTS" & "/" & "02_Musique"
	do shell script "mkdir " & nasPathMusic
	set nasPathExport to (quoted form of pathNasRefId) & "/" & "04_EXPORT"
	do shell script "mkdir " & nasPathExport
	set nasPathExportVideo to (quoted form of pathNasRefId) & "/" & "04_EXPORT" & "/" & "02_Vidéos"
	do shell script "mkdir " & nasPathExportVideo
	
	
	
	
	
	#CRÉATION DU FICHIER PROJET PREMIERE PREMIERE PRO EN FONCTION DU TEMPLATE
	set nameTemplate to "Template_" & clientName
	
	if clientName does not contain lsresult then
		set nameTemplate to "Template_SPECIAL_PROJECT"
		set pathSpecialProject to "/Volumes/VIDEOS_TMP/PRODUCTION_PremierePro/SPECIAL_PROJECT"
		set pathTemplate to pathSpecialProject & "/00_" & nameTemplate & "/" & nameTemplate & ".prproj"
		set destinationTemplate to pathNasClientName & "/01_REFERENCES" & "/" & refid & "/01_PROJET" & "/" & refid & ".prproj"
	end if
	
	set pathTemplate to pathNasClientName & "/00_" & nameTemplate & "/" & nameTemplate & ".prproj"
	set destinationTemplate to pathNasClientName & "/01_REFERENCES" & "/" & refid & "/01_PROJET" & "/" & refid & ".prproj"
	do shell script "cp " & (quoted form of pathTemplate) & " " & (quoted form of destinationTemplate)
	
	
	#NOTIFACTION DE FIN DE CRÉATION DES DOSSIER PROJET SUR LE NAS
	display notification "Le dossier de projet et ses sous-dossier on bien été créé ainsi que le transfert des médias" with title "Dossier de Projet NAS"
	
	
	
	
	#SUITE DU SCRIPT // CRÉER PROJET PREMIERE PRO SUR LE NAS
	
	
	
	
	display dialog "L'application Premiere Pro est elle déja lancer?" with icon note buttons {"Oui", "Non"} with title "Premiere Pro est elle déja lancer?"
	if the button returned of the result is "Oui" then
		
		display dialog "Ouverture du nouveau projet Premiere Pro à partir du Template_" & clientName with icon note buttons {"Non", "Oui"} with title "Ouvrir nouveau projet Premiere Pro"
		if the button returned of the result is "Non" then
			return
		end if
		
		
		#OUVERTURE DU NOUVEAU PROJET PREMIERE PRO
		delay 1
		do shell script "open " & (quoted form of destinationTemplate)
		
		
		#NOTIFACTION DE FIN DE L'ALGO
		display notification "L'algo à terminé toute ses tâches" with title "BON TRAVAIL"
		
		
	end if
	
	
	#NOTIFACTION DE FIN DE CRÉATION DU PROJET PREMIERE PRO
	display notification "Le nouveau projet Premiere Pro à partir du Template_" & clientName & " à bien été créé. Lancement de l'ouverture de Premiere Pro" with title "Création du nouveau projet Premiere Pro terminé"
	
	
	#LANCEMENT DE L'APPLICATION PREMIERE PRO ET OUVERTURE AUTOMATIQUE DU PANNEAU PRODUCTION
	set appname to "Adobe Premiere Pro 2020"
	tell application appname to launch
	
	
	delay 4 # depend de la puissance de l'ordinateur pour lancer completement l'appli
	
	
	#NOTIFACTION D'OUVERTURE DU PANNEAU PRODUCTION PREMIERE PRO
	display notification "Ouverture en cours du panneau \"production\" dans Premiere Pro" with title "Ouverture panneau PRODUCTION"
	
	
	delay 4 # depend de la puissance de l'ordinateur pour lancer completement l'appli
	
	
	tell application "Adobe Premiere Pro 2020" to activate
	tell application "System Events"
		tell application process "Adobe Premiere Pro 2020"
			key code 35 using {control down} #touche p+option
			key code 76 #touche enter
		end tell
	end tell
	
	
	#OUVERTURE DU NOUVEAU PROJET PREMIERE PRO
	delay 1
	do shell script "open " & (quoted form of destinationTemplate)
	
	
	
	
	##
	
	display dialog "Migrer les medias originaux sur le NAS" with icon note buttons {"Non", "Oui"} with title "Migrer les médias sur le NAS"
	if the button returned of the result is "Non" then
		return
	end if
	
	#RÉCUPÉRATION DES MEDIAS PROVENANT DU ZIP ORIGINAL
	do shell script "rsync -r " & pathVideoFolder & " " & (quoted form of pathNasRefId) # option -r => option de récurcivité 
	do shell script "rsync -r " & pathPhotosFolder & " " & nasPathExport
	
	
	
	#NOTIFACTION DE FIN DE L'ALGO
	display notification "L'algo à terminé toute ses tâches" with title "BON TRAVAIL"
	
end run