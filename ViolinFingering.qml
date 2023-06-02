//=============================================================================
//  Violin and Viola Fingering Plugin
//
//  Adds fingering for Violin and Viola to the score
//
//  Copyright (c) 2014 lalov
//                2016 HansPog & Christophe Corsi
//                2019 Johan Temmerman (jeetee)
//                2023 Joachim Schmitz (Jojo-Schmitz)
//=============================================================================
import QtQuick 2.2
import MuseScore 3.0

MuseScore {
	menuPath: "Plugins.Violin Fingering"
	version: "4.0"
	description: "Adds fingering for Violin and Viola to the score"
	requiresScore: true

	Component.onCompleted : {
		if (mscoreMajorVersion >= 4) {
			title = qsTr("Violin Fingering") ;
			// thumbnailName = ".png";
 			// categoryCode = "some_category";
 		}
	}

	onRun: {
		var textposition = 0.65;
		var startStaff;
		var endStaff;
		var endTick;
		var fullScore = false;

		//find out range to apply to, either selection or full score
		var cursor = curScore.newCursor();
		cursor.rewind(1); //start of selection
		if (!cursor.segment) { //no selection
			fullScore  = true;
			startStaff = 0; // start with 1st staff
			endStaff   = curScore.nstaves - 1; // and end with last
		}
		else {
			startStaff = cursor.staffIdx;
			cursor.rewind(2); //find end of selection
			if (cursor.tick == 0) {
				// this happens when the selection includes
				// the last measure of the score.
				// rewind(2) goes behind the last segment (where
				// there's none) and sets tick=0
				endTick = curScore.lastSegment.tick + 1;
			}
			else {
				endTick = cursor.tick;
			}
			endStaff = cursor.staffIdx;
		}
		console.log(startStaff + " - " + endStaff + " - " + endTick)

		curScore.startCmd()

		//loop over the selection
		for (var staff = startStaff; staff <= endStaff; staff++) {
			for (var voice = 0; voice < 4; voice++) {
				cursor.rewind(1); // beginning of selection
				cursor.voice    = voice;
				cursor.staffIdx = staff;

				if (fullScore) { // no selection
					cursor.rewind(0); // beginning of score
				}

				while (cursor.segment && (fullScore || cursor.tick < endTick)) {
					if (cursor.element && cursor.element.type == Element.CHORD) {
						var text = newElement(Element.STAFF_TEXT);
						text.autoplace = true;
						text.offsetX = textposition;
						text.align = 2;//Align.HCenter;
						
						var graceChords = cursor.element.graceNotes;
						for (var i = 0; i < graceChords.length; i++) {
							// iterate through all grace chords
							var notes = graceChords[i].notes;
							addFingerText(notes, text);
							// there seems to be no way of knowing the exact horizontal pos.
							// of a grace note, so we have to guess:
							text.offsetX = -2.5 * (graceChords.length - i);
							cursor.add(text);
							
							// new text for next element
							text  = newElement(Element.STAFF_TEXT);
							text.autoplace = true;
							text.offsetX = textposition;
							text.align = 2;//Align.HCenter;
						}

						var notes = cursor.element.notes;
						addFingerText(notes, text);
						cursor.add(text);
					} // end if CHORD
					cursor.next();
				} // end while segment
				
			} // end for voice
		} // end for staff

		curScore.endCmd()

		quit();
	}

	// match note with fingering text
	function addFingerText(notes, text) {
		var fingerings = [ 
			"0\nC", "1L\nC", "1\nC", "2L\nC", "2\nC", "3\nC", "3H\nC", 
			"0\nG", "1L\nG", "1\nG", "2L\nG", "2\nG", "3\nG", "3H\nG", 
			"0\nD", "1L\nD", "1\nD", "2L\nD", "2\nD", "3\nD", "3H\nD", 
			"0\nA", "1L\nA", "1\nA", "2L\nA", "2\nA", "3\nA", "3H\nA", 
			"0\nE", "1L\nE", "1\nE", "2L\nE", "2\nE", "3\nE", "3H\nE", "4\nE", 
			"1", "1", "2", "2", "3", "3",
		]
		var tuning = fingerings
		var lowestPitch = 48 //for the (alto)violin
		
		for (var i = 0; i < notes.length; i++) {
			var sep = "\n"; // change to "," if you want them horizontally
			if (i > 0) {
				text.text = fingerings[notes[i].pitch - lowestPitch];
			}
			
			if (typeof notes[i].pitch === "undefined") { // just in case
				return
			}
			if (typeof tuning[notes[i].pitch - lowestPitch] === "undefined") {
				text.text = "X";
			}
			else {
				text.text = tuning[notes[i].pitch - lowestPitch] + text.text;
			}
		}
	}

}
