==== README ====
Merci de tester ce ContractorMod.

Ce mod permet de simuler un nombre d�fini de personnage diff�rents durant une partie solo que vous controlez tour � tour.

La vid�o suivante montre un sc�nario de jeu utilisant le ContractorMod (enregistr� sur en version beta sur FS2013)
https://www.youtube.com/watch?v=xlj-0i8aMsc


Par d�faut, 4 personnages sont disponible Alex, Bob, Chris et David.
Au premier chargement d'une map ils sont positionn�s au point de d�part de la map.
D�s la premi�re sauvegarde, les positions/v�hicules des perso sont sauvegard�s et seront 
recharg�s au prochain chargement.


Les touches par d�faut pour passer d'un perso � l'autre sont:
 - SUIVANT   : Tab
 - PRECEDENT : Shift + Tab
Ces touches peuvent �tre personnalis�es et remplacent le switch standard de v�hicule qui est d�sactiv� dans le mod.


Ce mod est compatible avec les mods CoursePlay et FollowMe.
Ainsi, en mode FollowMe par exemple, un perso sera le Leader et un autre perso le Follower.


Le nom et et le nombre de perso peut �tre modifi� dans le fichier ContractorMod.xml pour les nouvelles parties.
Une fois la partie sauvegard�e, les modifications se font dans le fichier ContractorMod.xml du r�pertoire de sauvegarde habituel (savegame..)

==== Probl�mes connus ====
-Quand enableSeveralDrivers est valu� � true, le conducteur d'un v�hicule n'est plus affich� lorsqu'on quitte un vehicule encore occup� par un autre perso.
-Sur FS15, le conducteur apparait debout � l'int�rieur d'un vehicule juste apr�s le chargement d'une partie. Il apparait bien assis apr�s sa premi�re activation.
-Les perso � pied ne sont pas visible