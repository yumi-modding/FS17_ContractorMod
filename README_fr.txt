==== README ====
Merci de tester ce ContractorMod.

Ce mod permet de simuler un nombre défini de personnage différents durant une partie solo que vous controlez tour à tour.

La vidéo suivante montre un scénario de jeu utilisant le ContractorMod (enregistré sur en version beta sur FS2013)
https://www.youtube.com/watch?v=xlj-0i8aMsc


Par défaut, 4 personnages sont disponible Alex, Bob, Chris et David.
Au premier chargement d'une map ils sont positionnés au point de départ de la map.
Dès la première sauvegarde, les positions/véhicules des perso sont sauvegardés et seront 
rechargés au prochain chargement.


Les touches par défaut pour passer d'un perso à l'autre sont:
 - SUIVANT   : Tab
 - PRECEDENT : Shift + Tab
Ces touches peuvent être personnalisées et remplacent le switch standard de véhicule qui est désactivé dans le mod.


Ce mod est compatible avec la specialisation PassengerMod et avec les mods CoursePlay et FollowMe.
Ainsi, en mode FollowMe par exemple, un perso sera le Leader et un autre perso le Follower.


Le nom et et le nombre de perso peut être modifié dans le fichier ContractorMod.xml pour les nouvelles parties.
Une fois la partie sauvegardée, les modifications se font dans le fichier ContractorMod.xml du répertoire de sauvegarde habituel (savegame..)

==== Problèmes connus ====
-Quand enableSeveralDrivers est valué à true, le conducteur d'un véhicule n'est plus affiché lorsqu'on quitte un vehicule encore occupé par un autre perso.
-Sur FS15, le conducteur apparait debout à l'intérieur d'un vehicule juste après le chargement d'une partie. Il apparait bien assis après sa première activation.
-Les perso à pied ne sont pas visible