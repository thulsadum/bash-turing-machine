# Das ist ein Kommentar
A1+= #Dies ist die Alphabetedefinition (Standard ist 01," " [leerzeichen] ist immer definiert)
# @1+= #Alternative Schreibweise

I 111+111= #Das ist das Initialband der Maschine (Achtung: Leerzeichen gehört auch dazu!!)
# < 111+111= #Alternative Schreibweise

S1 #Start Status (Standard ist 0)
# !1 #Alternative Schreibweise

P1 #Startposition auf dem Band (Standard ist 0)
# .1 #Alternative Schreibweise

L20 #Länge des Bandes (Standard: 80)
# KEINE Alternative schreibweise

#Nun kommt das eigentliche Programm (Die Statusdefinitionen)
# Eine Statusdefinition besteht aus Komma getrennten Informationen der Art:
# Status, erwartetes Symbol auf dem Band, zu schreibendes Zeichen auf dem Band, Bewegung des Lese-/Schreibkopfes,neuer Status
#
# So besteht eine Beschreibung für einen Status aus mehreren Zeilen (eine für jedes mögliche Zeichen)

# Dieses Beispiel soll einen unären Addierer zeigen:
# 	Er schreibt das Ergebnis der Addition hinter dem Gleichheitszeichen.

# Status 1:
# 	Wenn eine "1" gelesen wird, lösche sie, gehe nach Rechts und zum Status 2
# 	Wenn ein  "+" gelesen wird, lösche es, gehe nach Rechts und zum Status 1
# 	Wenn ein  "=" gelesen wird, lösche es, bleib an der aktuellen Position und in den Endstatus
1,1, ,>,2
1,+, ,>,1
1,=, , ,F

# Status 2:
# 	Dieser Status schreibt die gelesen Zeichen auf's Band und bewegt sich nach rechts, 
# 	bis ein Leerzeichen gefunden wurde und schreibt dort eine 1 hinein, geht dann nach links und
# 	in den 3. Status über.
2,1,1,>,2
2,+,+,>,2
2,=,=,>,2
2, ,1,<,3

# Status 3:
# 	Der dritte Status macht, bewegt sich nach Links bis er das Ende (ein Leerzeichen erreicht),
# 	geht dann wieder einen Schritt nach rechts (auf die nun erste "1" [oder aber "+" oder "="])
# 	und geht in den ersten Zustand zurück
3,1,1,<,3
3,+,+,<,3
3,=,=,<,3
3, , ,>,1
